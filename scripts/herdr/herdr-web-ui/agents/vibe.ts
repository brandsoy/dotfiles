/**
 * Vibe adapter for herdr-web-ui's chat lens: reads the unified session store's
 * public projection (chunks + journal deltas) as conversation turns. Loaded
 * out-of-tree by the plugin's server/adapters.ts; deploy with
 * scripts/herdr/herdr-web-ui/sync.sh. The context carries the plugin's own
 * error classes so its route recognizes what this adapter throws.
 */
import { createHash } from "node:crypto";
import { readFileSync, readdirSync, readlinkSync, realpathSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { basename, isAbsolute, join, relative, sep } from "node:path";

/** The pieces server/adapters.ts passes in; structural so this file stands alone. */
export interface AdapterContext {
  herdrRpc<T = unknown>(method: string, params: Record<string, unknown>): Promise<T>;
  trimOutput(tool: ToolPart, output: string, ref: string): void;
  ConversationUnavailable: new (reason: string) => Error;
  HistoryChanged: new () => Error;
}

export interface ToolPart { kind: "tool"; name: string; summary: string; input: string; output: string; error: boolean; output_ref?: string; output_size?: number }
export type ConversationPart = { kind: "text"; text: string } | { kind: "thinking"; text: string } | { kind: "notice"; text: string; source: string } | ToolPart;
export interface ConversationTurn { role: "user" | "assistant"; ts: string; parts: ConversationPart[]; end_ts?: string }
export interface ConversationPage { before?: string; since?: string; from?: string }
export interface VibeConversation {
  source: "vibe-transcript";
  turns: ConversationTurn[];
  metadata: { model: null; reasoning_effort: null; context?: { used: number; window: null } };
  history_id: string;
  cursor: string | null;
  version: string;
}

export const defaultVibeStore = () => join(process.env["VIBE_HOME"] || join(homedir(), ".vibe"), "logs", "session");
const UUID = /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/;

/** Only an open session lease counts, not a stale PID marker or a recent same-cwd session. */
export function vibeSessionForPids(pids: number[], paths: string[], store = defaultVibeStore()): string | null {
  const ids = new Set<string>();
  for (const path of paths) {
    try {
      const id = basename(path, ".lock");
      if (!UUID.test(id) || realpathSync(path) !== realpathSync(join(store, "active", `${id}.lock`))) continue;
      const lease = JSON.parse(readFileSync(`${path}.json`, "utf8"));
      if (lease.session_id === id && pids.includes(lease.process_id)) ids.add(id);
    } catch { /* closed lease or unknown store */ }
  }
  return ids.size === 1 ? [...ids][0]! : null;
}

/** vibe-app-server (which holds the session lock) is a child of vibe-rs, not the foreground process. */
function descendantPids(roots: number[]): number[] {
  const parentOf = new Map<number, number>();
  if (process.platform === "linux") {
    try {
      for (const entry of readdirSync("/proc")) {
        if (!/^\d+$/.test(entry)) continue;
        try {
          const stat = readFileSync(`/proc/${entry}/stat`, "utf8");
          const match = stat.match(/^\d+ \(.+\) \w+ (\d+)/);
          if (match) parentOf.set(Number(entry), Number(match[1]));
        } catch { /* gone */ }
      }
    } catch { /* no /proc */ }
  } else {
    try {
      const result = Bun.spawnSync(["/bin/ps", "-eo", "pid,ppid"]);
      for (const line of new TextDecoder().decode(result.stdout).split("\n").slice(1)) {
        const parts = line.trim().split(/\s+/);
        if (parts.length >= 2) {
          const pid = Number(parts[0]), ppid = Number(parts[1]);
          if (Number.isInteger(pid) && Number.isInteger(ppid)) parentOf.set(pid, ppid);
        }
      }
    } catch { /* ps failed */ }
  }
  const childrenOf = new Map<number, number[]>();
  for (const [pid, ppid] of parentOf) {
    const list = childrenOf.get(ppid) ?? [];
    list.push(pid);
    childrenOf.set(ppid, list);
  }
  const found: number[] = [];
  const queue = [...roots];
  const seen = new Set(roots);
  while (queue.length) {
    const pid = queue.shift()!;
    for (const child of childrenOf.get(pid) ?? []) {
      if (!seen.has(child)) {
        seen.add(child);
        found.push(child);
        queue.push(child);
      }
    }
  }
  return found;
}

async function vibeSessionForPane(ctx: AdapterContext, paneId: string): Promise<string> {
  const info = await ctx.herdrRpc<{ process_info?: { foreground_processes?: { pid: number }[] } }>("pane.process_info", { pane_id: paneId });
  const foreground = (info.process_info?.foreground_processes ?? []).map(process => process.pid);
  const pids = [...new Set([...foreground, ...descendantPids(foreground)])];
  const paths: string[] = [];
  if (process.platform === "linux") {
    for (const pid of pids) {
      try {
        for (const fd of readdirSync(`/proc/${pid}/fd`)) {
          try { paths.push(readlinkSync(`/proc/${pid}/fd/${fd}`)); } catch { /* closed */ }
        }
      } catch { /* inaccessible process */ }
    }
  } else if (process.platform === "darwin" && pids.length) {
    const child = Bun.spawn(["/usr/sbin/lsof", "-nPbw", "-a", "-p", pids.join(","), "-Fn"], { stdout: "pipe", stderr: "ignore" });
    const timeout = setTimeout(() => child.kill(), 1500);
    try {
      const text = await new Response(child.stdout).text();
      await child.exited;
      paths.push(...text.split("\n").filter(line => line.startsWith("n")).map(line => line.slice(1)));
    } finally { clearTimeout(timeout); }
  }
  const id = vibeSessionForPids(pids, paths);
  if (!id) throw new ctx.ConversationUnavailable("no_session_path");
  return id;
}

/** Read public projection chunks and their journal deltas, never private runtime/model inputs. */
function vibeProjection(sessionId: string, store: string, ConversationUnavailable: AdapterContext["ConversationUnavailable"]) {
  if (!UUID.test(sessionId)) throw new ConversationUnavailable("invalid_session_id");
  const root = realpathSync(join(store, "unified", sessionId));
  const inside = relative(realpathSync(join(store, "unified")), root);
  if (!inside || inside.startsWith(`..${sep}`) || inside === ".." || isAbsolute(inside)) throw new ConversationUnavailable("outside_session_store");
  let budget = 32 * 1024 * 1024;
  // ponytail: bounded whole-projection reads; use incremental chunk caching for large histories.
  const read = (path: string): string => {
    const canonical = realpathSync(join(root, path));
    const rel = relative(root, canonical);
    if (isAbsolute(rel) || rel === ".." || rel.startsWith(`..${sep}`)) throw new ConversationUnavailable("outside_session_store");
    const size = statSync(canonical).size;
    if (size > budget) throw new ConversationUnavailable("vibe_projection_too_large");
    budget -= size;
    return readFileSync(canonical, "utf8");
  };
  const current = JSON.parse(read("CURRENT"));
  if (current.session_id !== sessionId || !/^\d{16}$/.test(current.generation) || current.store_format !== "mistral.vibe.unified-session-store/v1") throw new ConversationUnavailable("unknown_vibe_store");
  const generation = `generations/${current.generation}`;
  const manifestText = read(`${generation}/manifest.json`);
  if (createHash("sha256").update(manifestText.trimEnd()).digest("hex") !== current.manifest_sha256) throw new ConversationUnavailable("vibe_snapshot_changed");
  const manifest = JSON.parse(manifestText);
  if (manifest.session_id !== sessionId) throw new ConversationUnavailable("vibe_snapshot_changed");
  const projectionText = read(`${generation}/projection-state.json`);
  if (createHash("sha256").update(projectionText.trimEnd()).digest("hex") !== manifest.projection_state.sha256) throw new ConversationUnavailable("vibe_snapshot_changed");
  const projection = JSON.parse(projectionText);
  const entries = new Map<string, any>();
  for (const hash of manifest.projection_state.chunks) {
    if (!/^[a-f0-9]{64}$/.test(hash)) throw new ConversationUnavailable("invalid_vibe_chunk");
    const text = read(`chunks/${hash}.json`);
    if (createHash("sha256").update(text.trimEnd()).digest("hex") !== hash) throw new ConversationUnavailable("vibe_snapshot_changed");
    for (const entry of JSON.parse(text)) entries.set(entry.id, entry);
  }
  let envelope = projection.snapshot;
  const journalPath = manifest.recovery_journal_segment.path;
  if (!/^journal\/\d{16}\.jsonl$/.test(journalPath)) throw new ConversationUnavailable("invalid_vibe_journal");
  const journal = read(journalPath);
  for (const line of journal.split("\n").slice(0, -1)) {
    if (!line.trim()) continue;
    const record = JSON.parse(line);
    if (record.sequence <= current.snapshot_sequence || record.type !== "projection_delta") continue;
    for (const delta of record.payload.delta) {
      if (delta.op === "append_entry" || delta.op === "replace_entry") entries.set(delta.entry.id, delta.entry);
      else if (delta.op === "set_envelope") envelope = delta.state;
      else throw new ConversationUnavailable("unknown_vibe_delta");
    }
  }
  return { root, entries: [...entries.values()].filter(entry => entry.sessionId === sessionId), envelope };
}

function effectOutput(entry: any): string {
  const output = entry.state?.output;
  if (output?.structured_content) return JSON.stringify(output.structured_content, null, 2);
  if (Array.isArray(output?.content)) return output.content.filter((part: any) => part.type === "text").map((part: any) => part.text).join("\n");
  return entry.state?.error ? JSON.stringify(entry.state.error) : "";
}

export function vibeConversation(sessionId: string, page: ConversationPage, deps: Pick<AdapterContext, "trimOutput" | "ConversationUnavailable" | "HistoryChanged">, store = defaultVibeStore()): VibeConversation {
  try {
    const { root, entries, envelope } = vibeProjection(sessionId, store, deps.ConversationUnavailable);
    const historyId = createHash("sha256").update(root).digest("base64url");
    const turns: (ConversationTurn & { id: string })[] = [];
    for (const entry of entries) {
      const parts: ConversationPart[] = [];
      if (entry.type === "message" && (entry.role === "user" || entry.role === "assistant")) {
        for (const block of entry.content ?? []) {
          if (block.type === "text") parts.push({ kind: "text", text: block.text });
          else parts.push({ kind: "notice", text: "Attached file", source: "vibe" });
        }
      } else if (entry.type === "reasoning" && entry.text) parts.push({ kind: "thinking", text: entry.text });
      else if (entry.type === "effect" && entry.detail?.kind === "tool") {
        const tool: ToolPart = {
          kind: "tool", name: entry.detail.toolName, summary: entry.detail.display?.summary || entry.detail.toolName,
          input: JSON.stringify(entry.detail.input ?? {}), output: "", error: entry.state?.display?.success === false || entry.state?.status === "failed",
        };
        deps.trimOutput(tool, effectOutput(entry), entry.id);
        parts.push(tool);
      } else if (entry.type === "notice" && entry.level === "error") parts.push({ kind: "notice", text: entry.message, source: "vibe" });
      if (!parts.length) continue;
      const role = entry.role === "user" ? "user" : "assistant";
      let turn = turns.at(-1);
      if (!turn || role === "user" || turn.role !== role) {
        turn = { id: entry.id, role, ts: new Date(entry.createdAt).toISOString(), parts: [] };
        turns.push(turn);
      }
      turn.parts.push(...parts);
      if (role === "assistant" && entry.generationStatus === "completed") turn.end_ts = new Date(entry.updatedAt).toISOString();
    }
    const index = (cursor?: string): number | null => {
      if (cursor === undefined) return null;
      if (!cursor.startsWith(`${historyId}:`)) throw new deps.HistoryChanged();
      const found = turns.findIndex(turn => turn.id === cursor.slice(historyId.length + 1));
      if (found < 0) throw new deps.HistoryChanged();
      return found;
    };
    const before = index(page.before), since = index(page.since), from = index(page.from);
    const end = before ?? turns.length;
    if (since !== null && since > end) throw new deps.HistoryChanged();
    let start = Math.max(since ?? 0, end - 80);
    if (before === null && from !== null && from >= start) start = from;
    const answer = {
      source: "vibe-transcript" as const, turns: turns.slice(start, end).map(({ id, ...turn }) => turn),
      metadata: { model: null, reasoning_effort: null, ...(envelope.session?.contextUsage ? { context: { used: envelope.session.contextUsage.inputTokens, window: null } } : {}) },
      history_id: historyId, cursor: start > 0 ? `${historyId}:${turns[start]!.id}` : null,
    };
    return { ...answer, version: createHash("sha256").update(JSON.stringify(answer)).digest("base64url") };
  } catch (error) {
    if (error instanceof deps.HistoryChanged || error instanceof deps.ConversationUnavailable) throw error;
    throw new deps.ConversationUnavailable("vibe_projection_unavailable");
  }
}

export function vibeToolOutput(sessionId: string, ref: string, ConversationUnavailable: AdapterContext["ConversationUnavailable"], store = defaultVibeStore()): string | null {
  try {
    const entry = vibeProjection(sessionId, store, ConversationUnavailable).entries.find(entry => entry.id === ref && entry.type === "effect");
    return entry ? effectOutput(entry).slice(0, 2_000_000) : null;
  } catch { return null; }
}

/** What server/adapters.ts loads: pane -> open session lease -> conversation page / tool output. */
export function adapter(ctx: AdapterContext) {
  return {
    conversation: async (paneId: string, page: ConversationPage): Promise<VibeConversation> =>
      vibeConversation(await vibeSessionForPane(ctx, paneId), page, ctx),
    toolOutput: async (paneId: string, ref: string): Promise<string | null> =>
      vibeToolOutput(await vibeSessionForPane(ctx, paneId), ref, ctx.ConversationUnavailable),
  };
}

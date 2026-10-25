/**
 * PiG adapter for herdr-web-ui: PiG uses Pi's entry-tree session format but a
 * separate config/session store. A live PID, pane and socket must all match a
 * binding file before its session is offered, and the session file must live
 * inside a known PiG store. Loaded out-of-tree by server/adapters.ts; the
 * transcript rides the plugin's built-in pi reader.
 */
import { closeSync, constants, fstatSync, openSync, readFileSync, readlinkSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import { basename, dirname, isAbsolute, join, relative, resolve, sep } from "node:path";

/** The pieces server/adapters.ts passes in; structural so this file stands alone. */
export interface AdapterContext {
  herdrRpc<T = unknown>(method: string, params: Record<string, unknown>): Promise<T>;
  herdrSocketPath(): string;
}

export function pigAgentDirs(): string[] {
  const home = homedir();
  return [...new Set([
    process.env["PIG_CODING_AGENT_DIR"],
    process.env["PIG_HOME"] ? join(process.env["PIG_HOME"]!, "agent") : undefined,
    join(process.env["XDG_CONFIG_HOME"] || join(home, ".config"), "pig", "agent"),
    join(home, ".pig", "agent"),
  ].filter((dir): dir is string => Boolean(dir)))];
}

/** The pi reader's store check, inlined: a real .jsonl file inside the store, no symlink escapes. */
function sessionInStore(path: string, sessionDir: string): string | null {
  let canonical: string, root: string;
  try {
    canonical = realpathSync(path);
    root = realpathSync(sessionDir);
  } catch { return null; }
  const inside = relative(root, canonical);
  if (!inside || inside === ".." || inside.startsWith(`..${sep}`) || isAbsolute(inside)) return null;
  if (!canonical.endsWith(".jsonl")) return null;
  try {
    const fd = openSync(canonical, constants.O_RDONLY | constants.O_NONBLOCK);
    try { return fstatSync(fd).isFile() ? canonical : null; } finally { closeSync(fd); }
  } catch { return null; }
}

/** Bun on macOS cannot realpath a Unix socket; resolve its links and parent instead. */
function socketIdentity(path: string, links = 0): string {
  if (links > 8) throw new Error("Socket symlink loop");
  try {
    const target = readlinkSync(path);
    return socketIdentity(resolve(dirname(path), target), links + 1);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== "EINVAL") throw error;
    return join(realpathSync(dirname(path)), basename(path));
  }
}

/** A live PiG PID, pane and socket must all match. Never choose a file by cwd or recency. */
export function pigBoundTranscript(pid: number, paneId: string, socket: string, agentDirs = pigAgentDirs()): string | null {
  if (!Number.isSafeInteger(pid) || pid <= 0) return null;
  for (const dir of agentDirs) {
    try {
      const text = readFileSync(join(dir, "herdr", `${pid}.json`), "utf8");
      if (text.length > 16_384) continue;
      const binding = JSON.parse(text);
      if (binding.pid !== pid || binding.pane_id !== paneId || typeof binding.socket_path !== "string" ||
          socketIdentity(binding.socket_path) !== socketIdentity(socket) || typeof binding.session_file !== "string") continue;
      for (const sessionDir of process.env["PIG_CODING_AGENT_SESSION_DIR"]
        ? [process.env["PIG_CODING_AGENT_SESSION_DIR"]!]
        : agentDirs.map(agentDir => join(agentDir, "sessions"))) {
        const path = sessionInStore(binding.session_file, sessionDir);
        if (path) return path;
      }
    } catch { /* missing, stale, malformed or out-of-store binding: not evidence */ }
  }
  return null;
}

export async function pigTranscriptPath(ctx: AdapterContext, paneId: string): Promise<string | null> {
  const info = await ctx.herdrRpc<{ process_info?: { foreground_processes?: { pid: number; argv?: string[]; name?: string }[] } }>(
    "pane.process_info", { pane_id: paneId },
  ).catch(() => null);
  const paths = new Set<string>();
  for (const process of info?.process_info?.foreground_processes ?? []) {
    if (basename(process.argv?.[0] ?? process.name ?? "").replace(/\.exe$/i, "") !== "pig") continue;
    const path = pigBoundTranscript(process.pid, paneId, ctx.herdrSocketPath());
    if (path) paths.add(path);
  }
  return paths.size === 1 ? [...paths][0]! : null;
}

/** What server/adapters.ts loads: the pane's bound PiG session, parsed by the pi reader. */
export function adapter(ctx: AdapterContext) {
  return { transcript: (paneId: string) => pigTranscriptPath(ctx, paneId) };
}

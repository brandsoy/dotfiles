import { afterAll, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { type AdapterContext, vibeConversation, vibeSessionForPids, vibeToolOutput } from "./vibe.ts";

// the plugin passes its own classes; tests stand in for them
class ConversationUnavailable extends Error {}
class HistoryChanged extends Error {}
const deps: Pick<AdapterContext, "trimOutput" | "ConversationUnavailable" | "HistoryChanged"> = {
  ConversationUnavailable, HistoryChanged,
  trimOutput: (tool, output, ref) => {
    if (output.length <= 100) { tool.output = output; return; }
    tool.output = `${output.slice(0, 100)}\n… trimmed`;
    tool.output_ref = ref;
    tool.output_size = output.length;
  },
};

const store = mkdtempSync(join(tmpdir(), "herdr-vibe-"));
const id = "21f11251-8d05-45e1-dbcc-5dfb76900e28";
const root = join(store, "unified", id), gen = "0000000000000001";
for (const dir of ["chunks", `generations/${gen}`, "journal"]) mkdirSync(join(root, dir), { recursive: true });
const entries = Array.from({ length: 85 }, (_, i) => ({ id: `entry-${i}`, sessionId: id, type: "message", role: i % 2 ? "assistant" : "user", content: [{ type: "text", text: `message ${i}` }], createdAt: i * 1000, updatedAt: i * 1000 + 500, generationStatus: "completed" }));
const hash = (text: string) => createHash("sha256").update(text).digest("hex");
const chunk = JSON.stringify(entries), chunkHash = hash(chunk);
writeFileSync(join(root, "chunks", `${chunkHash}.json`), `${chunk}\n`);
const projection = JSON.stringify({ snapshot: { session: {} } });
writeFileSync(join(root, `generations/${gen}/projection-state.json`), `${projection}\n`);
const manifest = JSON.stringify({ session_id: id, projection_state: { chunks: [chunkHash], sha256: hash(projection) }, recovery_journal_segment: { path: "journal/0000000000000002.jsonl" } });
writeFileSync(join(root, `generations/${gen}/manifest.json`), `${manifest}\n`);
writeFileSync(join(root, "CURRENT"), JSON.stringify({ session_id: id, generation: gen, manifest_sha256: hash(manifest), snapshot_sequence: 1, store_format: "mistral.vibe.unified-session-store/v1" }));
const journalPath = join(root, "journal/0000000000000002.jsonl");
writeFileSync(journalPath, "");
afterAll(() => rmSync(store, { recursive: true, force: true }));

test("Vibe resolves only exact open leases for this pane's live processes", () => {
  mkdirSync(join(store, "active"));
  const lock = join(store, "active", `${id}.lock`);
  writeFileSync(lock, "");
  writeFileSync(`${lock}.json`, JSON.stringify({ process_id: 123, session_id: id }));
  expect(vibeSessionForPids([123], [lock], store)).toBe(id);
  expect(vibeSessionForPids([456], [lock], store)).toBeNull();
  expect(vibeSessionForPids([123], [], store)).toBeNull();
  const other = "47b19048-5666-1910-e8da-cf41700d4c16";
  const second = join(store, "active", `${other}.lock`);
  writeFileSync(second, "");
  writeFileSync(`${second}.json`, JSON.stringify({ process_id: 123, session_id: other }));
  expect(vibeSessionForPids([123], [lock, second], store)).toBeNull();
});

test("Vibe pages public turns and applies live projection replacements, not private journal inputs", () => {
  const latest = vibeConversation(id, {}, deps, store);
  expect(latest.turns).toHaveLength(80);
  expect(vibeConversation(id, { before: latest.cursor! }, deps, store).turns).toHaveLength(5);
  expect(vibeConversation(id, { from: latest.cursor! }, deps, store).turns).toEqual(latest.turns);
  expect(vibeConversation(id, {}, deps, store).version).toBe(latest.version);
  expect(() => vibeConversation(id, { before: "other:entry-5" }, deps, store)).toThrow(HistoryChanged);
  const effect = { id: "tool-1", sessionId: id, type: "effect", createdAt: 86000, updatedAt: 86500, generationStatus: "completed", detail: { kind: "tool", toolName: "bash", input: { command: "false" } }, state: { display: { success: false }, output: { content: [{ type: "text", text: "x".repeat(5000) }] } } };
  writeFileSync(journalPath, [
    { sequence: 2, type: "action_intent", payload: { text: "private system instructions" } },
    { sequence: 3, type: "projection_delta", payload: { delta: [
      { op: "replace_entry", id: "entry-84", entry: { ...entries[84], content: [{ type: "text", text: "live update" }] } },
      { op: "append_entry", entry: effect },
    ] } },
  ].map(record => JSON.stringify(record)).join("\n") + '\n{"partial":');
  const updated = vibeConversation(id, {}, deps, store);
  expect(updated.version).not.toBe(latest.version);
  expect(JSON.stringify(updated)).toContain("live update");
  expect(JSON.stringify(updated)).not.toContain("private system instructions");
  expect(updated.turns.at(-1)?.parts[0]).toMatchObject({ kind: "tool", error: true, output_ref: "tool-1", output_size: 5000 });
  expect(vibeToolOutput(id, "tool-1", ConversationUnavailable, store)).toHaveLength(5000);
  expect(vibeToolOutput(id, "another-tool", ConversationUnavailable, store)).toBeNull();
  writeFileSync(journalPath, "");
});

test("Vibe refuses traversal, corrupt chunks and out-of-store session links", () => {
  expect(() => vibeConversation("../private", {}, deps, store)).toThrow(ConversationUnavailable);
  const other = "47b19048-5666-1910-e8da-cf41700d4c16";
  symlinkSync(tmpdir(), join(store, "unified", other));
  expect(() => vibeConversation(other, {}, deps, store)).toThrow(ConversationUnavailable);
  writeFileSync(join(root, "chunks", `${chunkHash}.json`), "[]\n");
  expect(() => vibeConversation(id, {}, deps, store)).toThrow(ConversationUnavailable);
});

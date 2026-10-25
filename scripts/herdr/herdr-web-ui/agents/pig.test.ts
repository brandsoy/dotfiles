import { afterAll, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, realpathSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createServer } from "node:net";
import { pigBoundTranscript } from "./pig.ts";

const root = realpathSync(mkdtempSync(join(tmpdir(), "herdr-pig-")));
const agent = join(root, "agent"), socket = join(root, "herdr.sock");
mkdirSync(join(agent, "sessions"), { recursive: true });
mkdirSync(join(agent, "herdr"));
writeFileSync(socket, "");
afterAll(() => rmSync(root, { recursive: true, force: true }));
const path = join(agent, "sessions", "session.jsonl");
writeFileSync(path, [
  { type: "session", version: 3, id: "pig-session", cwd: root },
  { type: "message", id: "u", parentId: null, message: { role: "user", content: [{ type: "text", text: "hello pig" }] } },
].map(entry => JSON.stringify(entry)).join("\n") + "\n");
const binding = { pid: 123, pane_id: "w1:p2", socket_path: socket, session_file: path };
function bind(overrides: Record<string, unknown> = {}) {
  writeFileSync(join(agent, "herdr", "123.json"), JSON.stringify({ ...binding, ...overrides }));
}
const read = () => pigBoundTranscript(123, "w1:p2", socket, [agent]);

test("PiG binds the exact live pane and socket", () => {
  bind();
  expect(read()).toBe(path);
  const link = join(root, "socket-link");
  symlinkSync(socket, link);
  expect(pigBoundTranscript(123, "w1:p2", link, [agent])).toBe(path);
});

test("real Unix sockets are compared without Bun's unsupported socket realpath", async () => {
  const unix = join(root, "live.sock");
  const server = createServer();
  await new Promise<void>((done, reject) => { server.once("error", reject); server.listen(unix, done); });
  try {
    bind({ socket_path: unix });
    expect(pigBoundTranscript(123, "w1:p2", unix, [agent])).toBe(path);
  } finally {
    await new Promise<void>((done, reject) => server.close(error => error ? reject(error) : done()));
  }
});

test("PiG bindings and sessions can use different known config roots", () => {
  const markerAgent = join(root, "legacy-agent");
  mkdirSync(join(markerAgent, "herdr"), { recursive: true });
  writeFileSync(join(markerAgent, "herdr", "123.json"), JSON.stringify(binding));
  expect(pigBoundTranscript(123, "w1:p2", socket, [markerAgent, agent])).toBe(path);
  expect(pigBoundTranscript(123, "w1:p2", socket, [markerAgent])).toBeNull();
});

test("stale, cross-pane, cross-server, malformed and out-of-store bindings fail closed", () => {
  bind({ pid: 456 }); expect(read()).toBeNull();
  bind({ pane_id: "w1:p3" }); expect(read()).toBeNull();
  const otherSocket = join(root, "other.sock"); writeFileSync(otherSocket, "");
  bind({ socket_path: otherSocket }); expect(read()).toBeNull();
  const outside = join(root, "outside.jsonl"); writeFileSync(outside, "{}\n");
  bind({ session_file: outside }); expect(read()).toBeNull();
  const escape = join(agent, "sessions", "escape.jsonl"); symlinkSync(outside, escape);
  bind({ session_file: escape }); expect(read()).toBeNull();
  writeFileSync(join(agent, "herdr", "123.json"), "not json"); expect(read()).toBeNull();
  expect(pigBoundTranscript(999, "w1:p2", socket, [agent])).toBeNull();
  expect(pigBoundTranscript(-1, "w1:p2", socket, [agent])).toBeNull();
});

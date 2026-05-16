import { exec } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execAsync = promisify(exec);

async function getSystemTheme(): Promise<"dark" | "light"> {
  try {
    const { stdout } = await execAsync(
      "osascript -e 'tell application \"System Events\" to tell appearance preferences to return dark mode'",
    );
    return stdout.trim() === "true" ? "dark" : "light";
  } catch {
    return "dark";
  }
}

export default function (pi: ExtensionAPI) {
  let intervalId: ReturnType<typeof setInterval> | null = null;
  let currentTheme: "dark" | "light" | null = null;

  pi.on("session_start", async (_event, ctx) => {
    currentTheme = await getSystemTheme();
    ctx.ui.setTheme(currentTheme);

    intervalId = setInterval(async () => {
      const nextTheme = await getSystemTheme();
      if (nextTheme !== currentTheme) {
        currentTheme = nextTheme;
        ctx.ui.setTheme(nextTheme);
      }
    }, 2000);
  });

  pi.on("session_shutdown", () => {
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }
  });
}

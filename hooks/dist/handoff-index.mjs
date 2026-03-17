// src/handoff-index.ts
import * as fs from "fs";
import * as path from "path";
import { spawn } from "child_process";
async function main() {
  const input = JSON.parse(await readStdin());
  const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  if (input.tool_name !== "Write") {
    console.log(JSON.stringify({ result: "continue" }));
    return;
  }
  const filePath = input.tool_input?.file_path || "";
  if (!filePath.includes("handoffs") || !filePath.endsWith(".md")) {
    console.log(JSON.stringify({ result: "continue" }));
    return;
  }
  try {
    const fullPath = path.isAbsolute(filePath) ? filePath : path.join(projectDir, filePath);
    if (!fs.existsSync(fullPath)) {
      console.log(JSON.stringify({ result: "continue" }));
      return;
    }
    const content = fs.readFileSync(fullPath, "utf-8");
    const hasFrontmatter = content.startsWith("---");
    const hasSessionId = content.includes("session_id:");
    if (!hasSessionId) {
      const newFields = `session_id: ${input.session_id}`;
      let updated;
      if (hasFrontmatter) {
        updated = content.replace(/^---\n/, `---
${newFields}
`);
      } else {
        updated = `---
${newFields}
---

${content}`;
      }
      const tempPath = fullPath + ".tmp";
      fs.writeFileSync(tempPath, updated);
      fs.renameSync(tempPath, fullPath);
    }
    const indexScript = path.join(projectDir, "scripts", "artifact_index.py");
    if (fs.existsSync(indexScript)) {
      const child = spawn("uv", ["run", "python", indexScript, "--file", fullPath], {
        cwd: projectDir,
        detached: true,
        stdio: "ignore"
      });
      child.unref();
    }
    console.log(JSON.stringify({ result: "continue" }));
  } catch (err) {
    console.log(JSON.stringify({ result: "continue" }));
  }
}
async function readStdin() {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.on("data", (chunk) => data += chunk);
    process.stdin.on("end", () => resolve(data));
  });
}
main().catch(console.error);

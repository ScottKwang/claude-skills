import * as fs from 'fs';
import * as path from 'path';
import { spawn } from 'child_process';

interface PostToolUseInput {
  session_id: string;
  transcript_path: string;
  cwd: string;
  permission_mode: string;
  hook_event_name: string;
  tool_name: string;
  tool_input: {
    file_path?: string;
    content?: string;
  };
  tool_response: {
    success?: boolean;
    filePath?: string;
  };
  tool_use_id: string;
}

async function main() {
  const input: PostToolUseInput = JSON.parse(await readStdin());
  const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();

  // Only process Write tool calls
  if (input.tool_name !== 'Write') {
    console.log(JSON.stringify({ result: 'continue' }));
    return;
  }

  const filePath = input.tool_input?.file_path || '';

  // Only process handoff files
  if (!filePath.includes('handoffs') || !filePath.endsWith('.md')) {
    console.log(JSON.stringify({ result: 'continue' }));
    return;
  }

  try {
    const fullPath = path.isAbsolute(filePath) ? filePath : path.join(projectDir, filePath);

    if (!fs.existsSync(fullPath)) {
      console.log(JSON.stringify({ result: 'continue' }));
      return;
    }

    // Read current file content
    const content = fs.readFileSync(fullPath, 'utf-8');

    // Check if frontmatter has session_id, inject if missing
    const hasFrontmatter = content.startsWith('---');
    const hasSessionId = content.includes('session_id:');

    if (!hasSessionId) {
      const newFields = `session_id: ${input.session_id}`;
      let updated: string;

      if (hasFrontmatter) {
        updated = content.replace(/^---\n/, `---\n${newFields}\n`);
      } else {
        updated = `---\n${newFields}\n---\n\n${content}`;
      }

      const tempPath = fullPath + '.tmp';
      fs.writeFileSync(tempPath, updated);
      fs.renameSync(tempPath, fullPath);
    }

    // Trigger indexing if script exists (idempotent, will upsert)
    const indexScript = path.join(projectDir, 'scripts', 'artifact_index.py');

    if (fs.existsSync(indexScript)) {
      const child = spawn('uv', ['run', 'python', indexScript, '--file', fullPath], {
        cwd: projectDir,
        detached: true,
        stdio: 'ignore'
      });
      child.unref();
    }

    console.log(JSON.stringify({ result: 'continue' }));
  } catch (err) {
    // Don't block on errors
    console.log(JSON.stringify({ result: 'continue' }));
  }
}

async function readStdin(): Promise<string> {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.on('data', chunk => data += chunk);
    process.stdin.on('end', () => resolve(data));
  });
}

main().catch(console.error);

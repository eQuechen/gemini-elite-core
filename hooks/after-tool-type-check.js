import { spawnSync } from 'node:child_process';
import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

async function main() {
  const input = JSON.parse(readFileSync(0, 'utf8'));
  const { tool_name, cwd, hook_event_name } = input;

  // Only act on AfterTool for tools that modify files
  const modifyingTools = ['write_file', 'replace', 'run_shell_command'];
  if (hook_event_name !== 'AfterTool' || !modifyingTools.includes(tool_name)) {
    return;
  }

  // Check if it's a TypeScript project
  const tsconfigPath = join(cwd, 'tsconfig.json');
  if (!existsSync(tsconfigPath)) {
    return;
  }

  // Execute Type Check
  const result = spawnSync('bun', ['x', 'tsc', '--noEmit'], {
    cwd,
    encoding: 'utf8',
  });

  if (result.status !== 0) {
    // If errors found, format them for the agent
    const output = {
      systemMessage: `⚠️ [Gemini Elite Protocol] Type errors detected after the last change:\n\n${result.stdout || result.stderr}\n\nPlease fix these errors before proceeding.`, 
    };
    console.log(JSON.stringify(output));
  }
}

main().catch(() => process.exit(0));
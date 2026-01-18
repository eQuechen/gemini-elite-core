import { readFileSync } from 'node:fs';

async function main() {
  const input = JSON.parse(readFileSync(0, 'utf8'));
  const { hook_event_name, model_response } = input;

  if (hook_event_name !== 'AfterModel' || !model_response) {
    return;
  }

  // Look for common commit message patterns in the response
  const commitRegex = /(?:commit message|mensaje de commit|commit):\s*["']?`?(.*?)`?["']?$/im;
  // A bit more robust regex for English
  const match = model_response.match(/(?:suggested commit message|commit message|commit):\s*["']?`?(.*?)`?["']?$/im);
  
  const targetMsg = match ? match[1] : null;

  if (targetMsg) {
    const conventionalRegex = /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(?:\(.+\))?:\s.{1,72}/;

    if (!conventionalRegex.test(targetMsg)) {
      const output = {
        systemMessage: `🚨 [Gemini Elite Protocol] The suggested commit message ("${targetMsg}") does not follow Conventional Commits. \nPlease use the format: <type>(scope): <description>. Example: feat(auth): add login flow.`,
      };
      console.log(JSON.stringify(output));
    }
  }
}

main().catch(() => process.exit(0));
import { spawnSync } from 'node:child_process';

async function main() {
  const cyan = '\x1b[36m';
  const reset = '\x1b[0m';
  const magenta = '\x1b[35m';

  console.log(`\n${cyan}🚀 Gemini Elite Core v5.0 - Agentic V26 Edition${reset}`);
  console.log(`${magenta}Active Protocols: Auto-Type-Check, Commit-Sentinel, Planning-Guardian.${reset}\n`);

  // Check Bun
  const bunCheck = spawnSync('bun', ['--version']);
  if (bunCheck.status !== 0) {
    console.log('⚠️  Bun not detected. It is highly recommended to install Bun for optimal performance with Gemini Elite Core.');
  }
}

main().catch(() => process.exit(0));
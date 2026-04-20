import { listClawHubSkills, searchClawHubSkills } from "../src/infra/clawhub.js";
import { installSkillFromClawHub } from "../src/agents/skills-clawhub.js";
import { loadConfig } from "../src/config/config.js";
import { resolveAgentWorkspaceDir, resolveDefaultAgentId } from "../src/agents/agent-scope.js";
import fs from "node:fs/promises";
import path from "node:path";

async function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  const config = loadConfig();
  const workspaceDir = resolveAgentWorkspaceDir(config, resolveDefaultAgentId(config));
  
  let attempts = 0;
  let skillsResults: { slug: string; displayName?: string }[] = [];
  
  while (attempts < 3) {
    try {
      console.log("Listing all ClawHub skills...");
      const listRes = await listClawHubSkills({ limit: 1000 });
      if (listRes.items && listRes.items.length > 0) {
        skillsResults = listRes.items;
        break;
      }
      
      console.log("List returned empty, trying search with '*'...");
      const searchRes = await searchClawHubSkills({ query: "*", limit: 1000 });
      if (searchRes.length > 0) {
        skillsResults = searchRes.map(s => ({ slug: s.slug, displayName: s.displayName }));
        break;
      }

      console.log("Search with '*' returned empty, trying search with 'agent'...");
      const searchAgentRes = await searchClawHubSkills({ query: "agent", limit: 1000 });
      if (searchAgentRes.length > 0) {
        skillsResults = searchAgentRes.map(s => ({ slug: s.slug, displayName: s.displayName }));
        break;
      }
      
      break;
    } catch (err: any) {
      if (err.status === 429) {
        console.warn("Rate limited, waiting 10s...");
        await sleep(10000);
        attempts++;
      } else {
        throw err;
      }
    }
  }

  // De-duplicate skills by slug
  const uniqueSkills: Map<string, { slug: string; displayName?: string }> = new Map();
  for (const skill of skillsResults) {
    if (!uniqueSkills.has(skill.slug)) {
      uniqueSkills.set(skill.slug, skill);
    }
  }

  if (uniqueSkills.size === 0) {
    console.error("No skills found locally OR on ClawHub.");
    process.exit(1);
  }

  console.log(`Found ${uniqueSkills.size} unique skills on ClawHub.`);
  const sortedSkills = Array.from(uniqueSkills.values());

  const skillsDir = path.join(workspaceDir, "skills");
  await fs.mkdir(skillsDir, { recursive: true });
  const installedSkills: string[] = await fs.readdir(skillsDir).catch(() => []);

  for (const item of sortedSkills) {
    if (installedSkills.includes(item.slug)) {
      console.log(`Skill ${item.slug} is already installed. Skipping.`);
      continue;
    }

    console.log(`Installing new skill: ${item.slug}...`);
    try {
      const result = await installSkillFromClawHub({
        workspaceDir,
        slug: item.slug,
        logger: {
          info: (msg) => console.log(`[${item.slug}] ${msg}`),
        },
      });
      if (result.ok) {
        console.log(`Successfully installed ${item.slug}@${result.version}`);
      } else {
        console.error(`Failed to install ${item.slug}: ${result.error}`);
      }
      // Add a 5s delay between installs to avoid further rate limits
      await sleep(5000);
    } catch (err) {
      console.error(`Error installing ${item.slug}:`, err);
    }
  }
}

main().catch(err => {
  console.error("Fatal error:", err);
  process.exit(1);
});

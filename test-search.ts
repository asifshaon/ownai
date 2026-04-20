import { listClawHubSkills, searchClawHubSkills } from "./src/infra/clawhub.js";

async function run() {
  try {
    console.log("--- Testing listClawHubSkills ---");
    const listRes = await listClawHubSkills({});
    console.log("List results count:", listRes.items?.length);
    console.log("Full response:", JSON.stringify(listRes, null, 2));

    console.log("\n--- Testing searchClawHubSkills with 'agent' ---");
    const searchResults = await searchClawHubSkills({ query: "agent", limit: 100 });
    console.log("Search results count:", searchResults.length);
    if (searchResults.length > 0) {
       console.log("First search result:", JSON.stringify(searchResults[0], null, 2));
    }
  } catch (err: any) {
    console.error("Test failed:", err.message, err.status, err.responseBody);
  }
}

run();

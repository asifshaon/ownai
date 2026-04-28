# Troubleshooting & Incident Response

This document outlines the critical issues discovered during the initial Phase-1 deployment of the NEXUS AGI Gateway and their permanent solutions. 

---

## 1. The "Bootstrap Pending" Loop

### Symptom
When sending a message to the agent, the response is prepended with:
> `[Bootstrap pending] Please read BOOTSTRAP.md from the workspace and follow it...`

The agent refuses to answer normal queries and insists on running setup workflows.

### Root Cause
OpenClaw agents run a startup validation check. If the file `BOOTSTRAP.md` exists within the designated agent's `workspace` directory, the system forces a restricted "Bootstrap Mode". Because the NEXUS workspaces are stored persistently on a GCS bucket, the default `BOOTSTRAP.md` file from the initial container creation was retained permanently.

### Fix
Permanently delete the `BOOTSTRAP.md` files from the persistent GCS storage for all agents:
```bash
gcloud storage rm gs://openclaw-storage-ai-assistent-491400/workspace/core/BOOTSTRAP.md --project ai-assistent-491400
gcloud storage rm gs://openclaw-storage-ai-assistent-491400/workspace/agents/architect/BOOTSTRAP.md
gcloud storage rm gs://openclaw-storage-ai-assistent-491400/workspace/agents/scribe/BOOTSTRAP.md
gcloud storage rm gs://openclaw-storage-ai-assistent-491400/workspace/agents/blackteam/BOOTSTRAP.md
```

---

## 2. Infinite Loading Screen (API Key / Model Mismatch)

### Symptom
After typing a message and hitting send, the UI shows a permanent loading animation. However, if you refresh the browser page manually, the complete response appears in the chat history.

### Root Cause
The streaming LLM request was failing silently on the backend. This happens when the gateway attempts to call an LLM API provider with an invalid key or a model that doesn't exist, preventing the WebSocket stream generator from initializing. 
In our specific case, the `env-vars-nexus.yaml` was explicitly hardcoded to use `google/gemini-2.0-flash-exp` as the default model, but it was being provided an expired/invalid `GEMINI_API_KEY` (format: `AQ.Ab8RN...`), while the valid API key provided was for `OPENAI_API_KEY`.

### Fix
Ensure the `OPENCLAW_CONFIG_OVERRIDE` in `env-vars-nexus.yaml` specifies a default model that corresponds to the valid API key provided. 
```json
"defaults":{"model":"openai/gpt-4o","sandbox":{"mode":"off"}}
```
Once redeployed, the OpenAI key will authenticate correctly, and the stream will push tokens to the UI instantly.

---

## 3. GCSFuse SQLite Deadlock (stale file handle)

### Symptom
Cloud Run logs (`stdout` / `stderr`) are flooded with errors like:
```text
WriteFile: stale file handle... file was clobbered due to generation/metageneration mismatch
ReadFile: stale file handle... storage: object doesn't exist
```

### Root Cause
If `OPENCLAW_STATE_DIR` is pointed to a directory mounted by GCSFuse (e.g. `OPENCLAW_STATE_DIR=/home/node/.openclaw` while mounting GCS to `/home/node/.openclaw`), the system will attempt to write its high-frequency SQLite session database (`tasks/runs.sqlite-shm`) and WebSocket session `.jsonl` appends to the network drive. GCSFuse **does not support concurrent file locking**, causing the writes to collide, corrupt, and ultimately crash the WebSocket streaming worker.

### Fix (The Split-State Architecture)
Do **not** mount GCS to the `OPENCLAW_STATE_DIR`. 
1. Mount the GCS bucket to a separate path: `--add-volume-mount="volume=nexus-data,mount-path=/mnt/nexus-data"`
2. Omit `OPENCLAW_STATE_DIR` entirely from the environment variables, forcing the SQLite database to run on the ephemeral, high-speed container disk.
3. Update the agent workspaces in the `OPENCLAW_CONFIG_OVERRIDE` JSON to explicitly target the GCS mount (`/mnt/nexus-data/workspace/...`), preserving long-term memory while allowing ephemeral live-streaming.

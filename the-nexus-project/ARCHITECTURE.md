# NEXUS Architecture

NEXUS is deployed as a serverless containerized application using **Google Cloud Run**. It relies heavily on high-speed compute, ephemeral disk storage for real-time operations, and Google Cloud Storage (GCS) for long-term agent memory and identity retention.

## Infrastructure Diagram

```mermaid
graph TD
    Client[Browser UI / Control Tower] --> |WebSocket / HTTP| Gateway(Cloud Run: nexus-gateway)
    
    subgraph "Ephemeral Container Storage"
        Gateway --> |SQLite Writes| StateDir[/tmp or /home/node/.openclaw]
        Gateway --> |Live Chat JSONL| StateDir
    end
    
    subgraph "Persistent Storage (GCSFuse)"
        Gateway --> |Agent Memories / Config| GCSMount[/mnt/nexus-data/workspace/]
        GCSMount --> |Bucket| GCSBucket[(openclaw-storage...)]
    end
    
    Gateway --> |API Calls| OpenAI[OpenAI API (gpt-4o)]
    Gateway --> |API Calls| Gemini[Google Gemini API]
```

## The "Split-State" Storage Paradigm

OpenClaw natively expects a single `OPENCLAW_STATE_DIR` to handle both **high-frequency runtime data** (like SQLite session databases and live `.jsonl` streaming logs) and **long-term configuration/memory data** (like Agent `SOUL.md` and `MEMORY.md` files).

However, NEXUS implements a **Split-State Architecture** to bypass severe performance bottlenecks:

1. **High-Frequency Ephemeral State**:
   - The runtime state directory is left default (running on the container's native, ephemeral Linux filesystem).
   - This prevents `stale file handle` crashes from GCSFuse when the LLM attempts to stream tokens rapidly to the UI. SQLite database locking mechanisms (`.sqlite-shm`, `.sqlite-wal`) require POSIX-compliant file locking, which network drives (like GCSFuse) cannot provide reliably at high speeds.
   - *Trade-off*: Real-time UI session history is ephemeral to the life of the container instance.

2. **Persistent Agent Workspaces**:
   - The GCS bucket is mounted specifically to `/mnt/nexus-data`.
   - The agent workspaces are explicitly directed to this mount via the `OPENCLAW_CONFIG_OVERRIDE` in the environment variables.
   - This ensures that while chat session streams are ephemeral, the **brains and memories** of the NEXUS agents are permanently persisted across container reboots.

## Security & Access
- The UI currently runs with `dangerouslyDisableDeviceAuth: true` and `dangerouslyAllowHostHeaderOriginFallback: true` for ease of developer access.
- For production scaling, these will be replaced with explicit authentication tokens.
- **Port Binding**: Bound to port `8080` internally on Cloud Run, mapped to standard `HTTPS 443` externally.

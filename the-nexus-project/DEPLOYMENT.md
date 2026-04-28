# Deployment Guide

The `nexus-gateway` is deployed via Google Cloud Build and Google Cloud Run. 

## 1. Prerequisites
- Google Cloud SDK (`gcloud`) installed locally.
- Authenticated with the target GCP project (`ai-assistent-491400`).
- Ensure the API Keys (OpenAI, Google) are valid and have sufficient quota.

## 2. Environment Variables Configuration
The deployment relies on a complex YAML file (`env-vars-nexus.yaml`). Due to the heavily nested JSON in the `OPENCLAW_CONFIG_OVERRIDE`, the YAML string uses the folded block scalar `>-` to ensure proper parsing by Cloud Run.

Key environment variables:
- `OPENCLAW_GATEWAY_TOKEN`: The secure access token for the UI.
- `OPENCLAW_SKIP_CHANNELS: "1"`: Disables unused integrations (like WhatsApp FUSE nodes) to save memory.
- `OPENAI_API_KEY`: The primary LLM key used for generation.

**Note on `OPENCLAW_STATE_DIR`**: 
Do **NOT** set `OPENCLAW_STATE_DIR` if you are using GCSFuse. It must be omitted so the system falls back to the ephemeral disk for high-frequency SQLite operations (see Architecture).

## 3. Building the Image
If code changes have been made to the core OpenClaw repo on the `nexus/phase-1` branch, trigger a rebuild:

```bash
gcloud builds submit --config cloudbuild.nexus.yaml . \
  --project ai-assistent-491400
```
This builds the Docker image and pushes it to the Google Container Registry (`gcr.io/ai-assistent-491400/nexus-gateway`).

## 4. Deploying to Cloud Run
To deploy the gateway and attach the Google Cloud Storage bucket for persistent agent workspaces, execute:

```bash
gcloud run deploy nexus-gateway \
  --image "gcr.io/ai-assistent-491400/nexus-gateway" \
  --region "us-central1" \
  --add-volume="name=nexus-data,type=cloud-storage,bucket=openclaw-storage-ai-assistent-491400" \
  --add-volume-mount="volume=nexus-data,mount-path=/mnt/nexus-data" \
  --env-vars-file env-vars-nexus.yaml \
  --project ai-assistent-491400
```

## 5. Verifying Deployment
Check the readiness of the system by curling the health endpoint:
```bash
curl -s https://nexus-gateway-21483412225.us-central1.run.app/readyz
# Expected output: {"ready":true}
```

#!/bin/bash
# ============================================================================
# NEXUS Cloud Run Gateway Deployment
# Deploys the OpenClaw gateway to Cloud Run with NEXUS configuration
# ============================================================================

set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-ai-assistent-491400}"
REGION="${GCP_REGION:-us-central1}"
SERVICE_NAME="${SERVICE_NAME:-nexus-gateway}"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
STORAGE_BUCKET="${STORAGE_BUCKET:-openclaw-storage-${PROJECT_ID}}"

# Load environment variables from .env if present
if [ -f .env ]; then
    echo "📜 Loading environment variables from .env..."
    # Export variables from .env, excluding comments and empty lines
    export $(grep -v '^#' .env | xargs)
fi

echo "🧿 NEXUS Gateway Deployment"
echo "==========================="
echo "Project:  $PROJECT_ID"
echo "Region:   $REGION"
echo "Service:  $SERVICE_NAME"
echo ""

# --------------------------------------------------------------------------
# Step 1: Build using Cloud Build (Server-side)
# --------------------------------------------------------------------------
echo "🔨 Building with Cloud Build (injecting security tools)..."
gcloud builds submit --config cloudbuild.nexus.yaml . \
    --project="$PROJECT_ID"

# --------------------------------------------------------------------------
# Step 2: Prepare Configuration Override
# --------------------------------------------------------------------------
echo "⚙️ Preparing NEXUS Configuration Override..."
NEXUS_CONFIG=$(cat nexus/config/nexus-openclaw.json | jq -c .)

# --------------------------------------------------------------------------
# Step 3: Deploy to Cloud Run
# --------------------------------------------------------------------------
echo "🚀 Deploying to Cloud Run..."
MSYS_NO_PATHCONV=1 gcloud run deploy "$SERVICE_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --image="$IMAGE_NAME" \
    --platform=managed \
    --allow-unauthenticated \
    --port=4141 \
    --cpu=2 \
    --memory=2Gi \
    --timeout=3600 \
    --min-instances=0 \
    --max-instances=1 \
    --set-env-vars="OPENCLAW_SKIP_AUTH_SETUP=1" \
    --set-env-vars="GOOGLE_API_KEY=${GOOGLE_API_KEY:-}" \
    --set-env-vars="GEMINI_API_KEY=${GEMINI_API_KEY:-}" \
    --set-env-vars="OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN:-}" \
    --set-env-vars="OPENCLAW_CONFIG_OVERRIDE=$NEXUS_CONFIG" \
    --set-env-vars="EXTENSIONS=gemini" \
    --execution-environment=gen2 \
    --add-volume=name=openclaw-storage,type=cloud-storage,bucket="$STORAGE_BUCKET" \
    --add-volume-mount=volume=openclaw-storage,mount-path=/home/node/.openclaw

# --------------------------------------------------------------------------
# Get service URL
# --------------------------------------------------------------------------
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --format="value(status.url)")

echo ""
echo "============================================"
echo "🧿 NEXUS Gateway Deployed"
echo "============================================"
echo "URL: $SERVICE_URL"
echo ""
echo "Dashboard: $SERVICE_URL"
echo "============================================"

#!/bin/bash
set -e

# ==============================================================================
# PhiX-Grade OpenClaw Cloud Run FUSE Deployment Script
# ==============================================================================
# This script provisions the necessary infrastructure and deploys the OpenClaw
# Gateway to Google Cloud Run with a Cloud Storage FUSE persistent mount
# and Firestore session synchronization.

PROJECT_ID="ai-assistent-491400"
REGION="us-central1"
SERVICE_NAME="openclaw-gateway"
BUCKET_NAME="openclaw-storage-ai-assistent-491400"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"

export MSYS_NO_PATHCONV=1
GCLOUD_PATH="C:\Google-Cloud-SDK-Archive\google-cloud-sdk\bin\gcloud.cmd"

echo "Deploying OpenClaw to project: $PROJECT_ID"
"$GCLOUD_PATH" config set project "$PROJECT_ID"

echo "1. Enabling required APIs..."
"$GCLOUD_PATH" services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  firestore.googleapis.com

echo "2. Building and pushing Docker image to GCR via Cloud Build..."
# Ensure we are in the repository root
"$GCLOUD_PATH" builds submit --config cloudbuild.yaml --substitutions=_IMAGE_NAME="$IMAGE_NAME" .

echo "3. Provisioning Google Cloud Storage Bucket for FUSE mount..."
# Create the bucket if it doesn't exist
if ! "$GCLOUD_PATH" storage ls "gs://$BUCKET_NAME" >/dev/null 2>&1; then
  echo "Creating bucket gs://$BUCKET_NAME..."
  "$GCLOUD_PATH" storage buckets create "gs://$BUCKET_NAME" --location="$REGION"
else
  echo "Bucket gs://$BUCKET_NAME already exists, reusing it."
fi

echo "4. Granting Default Compute Service Account access to the bucket..."
PROJECT_NUMBER=$("$GCLOUD_PATH" projects describe "$PROJECT_ID" --format="value(projectNumber)")
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
"$GCLOUD_PATH" storage buckets add-iam-policy-binding "gs://$BUCKET_NAME" --member="serviceAccount:${COMPUTE_SA}" --role="roles/storage.objectAdmin"

echo "5. Deploying Cloud Run Service with Gen 2 Execution Environment and FUSE Mount..."
# Generate a random initial token
GATEWAY_TOKEN=$(openssl rand -hex 16)

"$GCLOUD_PATH" run deploy "$SERVICE_NAME" \
  --image "$IMAGE_NAME" \
  --region "$REGION" \
  --allow-unauthenticated \
  --execution-environment gen2 \
  --add-volume="name=openclaw-data,type=cloud-storage,bucket=$BUCKET_NAME" \
  --add-volume-mount="volume=openclaw-data,mount-path=/home/node/.openclaw" \
  --set-env-vars="OPENCLAW_GATEWAY_TOKEN=$GATEWAY_TOKEN,OPENCLAW_GATEWAY_BIND=lan,OPENCLAW_GATEWAY_PORT=8080,OPENCLAW_SESSION_STORE_DRIVER=file,OPENCLAW_GATEWAY_CONTROL_UI_ALLOWED_ORIGINS=*,OPENCLAW_GATEWAY_CONTROL_UI_DANGEROUSLY_ALLOW_HOST_HEADER_ORIGIN_FALLBACK=1,ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-},GOOGLE_API_KEY=${GOOGLE_API_KEY:-},GEMINI_API_KEY=${GEMINI_API_KEY:-},GROQ_API_KEY=${GROQ_API_KEY:-},CEREBRAS_API_KEY=${CEREBRAS_API_KEY:-}" \
  --port 8080 \
  --memory 2048Mi \
  --cpu 2 \
  --timeout 3600 \
  --cpu-boost

echo ""
echo "========================================================================"
echo "Deployment Complete!"
echo "Service URL: $("$GCLOUD_PATH" run services describe $SERVICE_NAME --region $REGION --format='value(status.url)')"
echo "Gateway Token: $GATEWAY_TOKEN"
echo "========================================================================"
echo "You can securely access your deployed OpenClaw dashboard at the Service URL."
echo "Use the Gateway Token when connecting your devices or accessing the Control UI."

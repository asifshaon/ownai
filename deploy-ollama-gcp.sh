#!/bin/bash
set -e

# ==============================================================================
# PhiX-Grade Ollama & Open WebUI Cloud Deployment Script
# ==============================================================================
# This script provisions:
# 1. A GCE Instance with NVIDIA GPU and Ollama installed.
# 2. A Cloud Run service for Open WebUI, connected to the Ollama instance.
#
# Prerequisite: Ensure you have a GPU quota for us-central1 (NVIDIA L4 or T4).

PROJECT_ID="ai-assistent-491400"
REGION="us-central1"
ZONE="us-central1-a"
OLLAMA_INSTANCE_NAME="ollama-core"
OLLAMA_IP_NAME="ollama-static-ip"
WEBPLAYER_SERVICE_NAME="open-webui"
WEBPLAYER_IMAGE="ghcr.io/open-webui/open-webui:main"

# Path to gcloud (as seen in deploy-cloudrun.sh)
GCLOUD_PATH="C:\Google-Cloud-SDK-Archive\google-cloud-sdk\bin\gcloud.cmd"

echo "Deploying Ollama & Open WebUI to project: $PROJECT_ID"

echo "1. Enabling required APIs..."
"$GCLOUD_PATH" services enable \
  compute.googleapis.com \
  run.googleapis.com \
  iam.googleapis.com

echo "2. Reserving a static IP for Ollama..."
if ! "$GCLOUD_PATH" compute addresses describe "$OLLAMA_IP_NAME" --region="$REGION" >/dev/null 2>&1; then
  "$GCLOUD_PATH" compute addresses create "$OLLAMA_IP_NAME" --region="$REGION"
else
  echo "Static IP $OLLAMA_IP_NAME already exists."
fi
OLLAMA_IP=$("$GCLOUD_PATH" compute addresses describe "$OLLAMA_IP_NAME" --region="$REGION" --format="value(address)")

echo "3. Provisioning GCE Instance for Ollama (L4 GPU)..."
if ! "$GCLOUD_PATH" compute instances describe "$OLLAMA_INSTANCE_NAME" --zone="$ZONE" >/dev/null 2>&1; then
  # We use L4 GPU (available in many us-central1 zones) which is excellent for LLMs.
  # Machine type g2-standard-4 provides enough VRAM and CPU performance.
  "$GCLOUD_PATH" compute instances create "$OLLAMA_INSTANCE_NAME" \
    --zone="$ZONE" \
    --machine-type="g2-standard-4" \
    --accelerator="count=1,type=nvidia-l4" \
    --maintenance-policy="TERMINATE" \
    --provisioning-model="STANDARD" \
    --subnet="default" \
    --address="$OLLAMA_IP" \
    --tags="http-server,https-server,ollama-api" \
    --image-family="common-cu124-debian-11-py310" \
    --image-project="deeplearning-platform-release" \
    --boot-disk-size="100GB" \
    --boot-disk-type="pd-balanced" \
    --metadata="startup-script=#!/bin/bash
      # Install Ollama
      curl -fsSL https://ollama.com/install.sh | sh
      # Background Ollama
      OLLAMA_HOST=0.0.0.0:11434 ollama serve &
      # Pre-pull models (optional but recommended)
      # sleep 30 && ollama pull llama-3.2:3b
    "
else
  echo "Instance $OLLAMA_INSTANCE_NAME already exists."
fi

echo "4. Configuring Firewall for Ollama API..."
if ! "$GCLOUD_PATH" compute firewall-rules describe "allow-ollama-api" >/dev/null 2>&1; then
  "$GCLOUD_PATH" compute firewall-rules create "allow-ollama-api" \
    --allow tcp:11434 \
    --target-tags="ollama-api" \
    --description="Allow Ollama API access"
else
  echo "Firewall rule allow-ollama-api already exists."
fi

echo "5. Deploying Open WebUI to Cloud Run..."
"$GCLOUD_PATH" run deploy "$WEBPLAYER_SERVICE_NAME" \
  --image "$WEBPLAYER_IMAGE" \
  --region "$REGION" \
  --allow-unauthenticated \
  --set-env-vars="OLLAMA_BASE_URL=http://${OLLAMA_IP}:11434" \
  --memory 2048Mi \
  --cpu 1 \
  --timeout 3600

echo ""
echo "========================================================================"
echo "Deployment Complete!"
echo "Ollama API IP: $OLLAMA_IP"
echo "Open WebUI Service URL: $("$GCLOUD_PATH" run services describe $WEBPLAYER_SERVICE_NAME --region $REGION --format='value(status.url)')"
echo "========================================================================"
echo "To use this Ollama instance with your OpenClaw Gateway, ensure the OPENCLAW_OLLAMA_HOST"
echo "is set to http://${OLLAMA_IP}:11434 in your Cloud Run env vars."

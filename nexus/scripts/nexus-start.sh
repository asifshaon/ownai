#!/bin/bash
# Start the NEXUS GCE sandbox instance
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-ai-assistent-491400}"
ZONE="${GCP_ZONE:-us-central1-a}"
INSTANCE_NAME="${INSTANCE_NAME:-nexus-sandbox}"

echo "🚀 Starting NEXUS sandbox..."
gcloud compute instances start "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE"

echo "⏳ Waiting for instance to boot..."
sleep 20

echo "🐳 Starting Docker containers..."
gcloud compute ssh "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --tunnel-through-iap \
    --command="cd /home/nexus && sudo docker compose -f docker-compose.nexus.yml up -d"

echo "✅ NEXUS sandbox is running."

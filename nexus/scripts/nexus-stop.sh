#!/bin/bash
# Stop the NEXUS GCE sandbox instance (saves money)
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-ai-assistent-491400}"
ZONE="${GCP_ZONE:-us-central1-a}"
INSTANCE_NAME="${INSTANCE_NAME:-nexus-sandbox}"

echo "🛑 Stopping NEXUS sandbox..."

# Stop Docker containers first
gcloud compute ssh "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --tunnel-through-iap \
    --command="cd /home/nexus && sudo docker compose -f docker-compose.nexus.yml down" \
    2>/dev/null || true

# Stop the instance
gcloud compute instances stop "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE"

echo "✅ NEXUS sandbox stopped. No compute charges while stopped."

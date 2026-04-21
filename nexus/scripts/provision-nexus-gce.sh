#!/bin/bash
# ============================================================================
# NEXUS GCE Provisioning Script
# Provisions a Google Compute Engine Spot instance for NEXUS sandbox containers
# ============================================================================

set -euo pipefail

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-ai-assistent-491400}"
ZONE="${GCP_ZONE:-us-central1-a}"
INSTANCE_NAME="${INSTANCE_NAME:-nexus-sandbox}"
MACHINE_TYPE="${MACHINE_TYPE:-e2-standard-2}"
DISK_SIZE="${DISK_SIZE:-50}"
DISK_TYPE="pd-ssd"

echo "🧿 NEXUS GCE Provisioning"
echo "========================="
echo "Project:  $PROJECT_ID"
echo "Zone:     $ZONE"
echo "Instance: $INSTANCE_NAME"
echo "Machine:  $MACHINE_TYPE"
echo "Disk:     ${DISK_SIZE}GB SSD"
echo ""

# --------------------------------------------------------------------------
# Step 1: Create SSH keypair for OpenClaw sandbox backend
# --------------------------------------------------------------------------
echo "🔑 Generating SSH keypair..."
SSH_KEY_DIR="$(dirname "$0")/../config"
mkdir -p "$SSH_KEY_DIR"

if [ ! -f "$SSH_KEY_DIR/nexus_key" ]; then
    ssh-keygen -t ed25519 -f "$SSH_KEY_DIR/nexus_key" -N "" -C "nexus-sandbox"
    echo "  Key generated: $SSH_KEY_DIR/nexus_key"
else
    echo "  Key already exists: $SSH_KEY_DIR/nexus_key"
fi

# --------------------------------------------------------------------------
# Step 2: Create startup script
# --------------------------------------------------------------------------
echo "📜 Creating startup script..."
cat << 'STARTUP' > /tmp/nexus-startup.sh
#!/bin/bash
set -e

# Install Docker
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d'"' -f4)
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Add nexus user
if ! id -u nexus &>/dev/null; then
    useradd -m -s /bin/bash -G docker nexus
fi

# Setup SSH for nexus user
mkdir -p /home/nexus/.ssh
chmod 700 /home/nexus/.ssh
chown nexus:nexus /home/nexus/.ssh

echo "NEXUS GCE startup complete."
STARTUP

# --------------------------------------------------------------------------
# Step 3: Create the GCE instance (Spot/Preemptible)
# --------------------------------------------------------------------------
echo "🖥️  Creating GCE Spot instance..."
gcloud compute instances create "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP \
    --boot-disk-size="${DISK_SIZE}GB" \
    --boot-disk-type="$DISK_TYPE" \
    --image-family="ubuntu-2404-lts-amd64" \
    --image-project="ubuntu-os-cloud" \
    --metadata-from-file=startup-script=/tmp/nexus-startup.sh \
    --tags="nexus-sandbox" \
    --scopes="default" \
    --no-address \
    2>/dev/null || echo "Instance may already exist"

# --------------------------------------------------------------------------
# Step 4: Create firewall rules
# --------------------------------------------------------------------------
echo "🔥 Configuring firewall..."

# Allow SSH only via IAP (Identity-Aware Proxy) — no public IP needed
gcloud compute firewall-rules create "allow-iap-ssh-nexus" \
    --project="$PROJECT_ID" \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges="35.235.240.0/20" \
    --target-tags="nexus-sandbox" \
    2>/dev/null || echo "Firewall rule may already exist"

# Deny all other inbound
gcloud compute firewall-rules create "deny-all-nexus" \
    --project="$PROJECT_ID" \
    --direction=INGRESS \
    --priority=2000 \
    --network=default \
    --action=DENY \
    --rules=all \
    --source-ranges="0.0.0.0/0" \
    --target-tags="nexus-sandbox" \
    2>/dev/null || echo "Firewall rule may already exist"

# --------------------------------------------------------------------------
# Step 5: Wait for instance and copy SSH key
# --------------------------------------------------------------------------
echo "⏳ Waiting for instance to be ready..."
sleep 30

echo "🔑 Copying SSH public key to instance..."
gcloud compute ssh "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --tunnel-through-iap \
    --command="sudo mkdir -p /home/nexus/.ssh && sudo tee /home/nexus/.ssh/authorized_keys" \
    < "$SSH_KEY_DIR/nexus_key.pub"

# --------------------------------------------------------------------------
# Step 6: Copy Docker files and build
# --------------------------------------------------------------------------
echo "📦 Copying NEXUS Docker files..."
NEXUS_DIR="$(dirname "$0")/.."

gcloud compute scp \
    "$NEXUS_DIR/Dockerfile.sandbox-kali" \
    "$NEXUS_DIR/Dockerfile.sandbox-ubuntu" \
    "$NEXUS_DIR/docker-compose.nexus.yml" \
    "$INSTANCE_NAME:/home/nexus/" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --tunnel-through-iap

echo "🔨 Building Docker images on GCE (this takes 10-20 minutes)..."
gcloud compute ssh "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --tunnel-through-iap \
    --command="cd /home/nexus && sudo docker compose -f docker-compose.nexus.yml build"

# --------------------------------------------------------------------------
# Step 7: Start the sandbox stack
# --------------------------------------------------------------------------
echo "🚀 Starting NEXUS sandbox stack..."
gcloud compute ssh "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --tunnel-through-iap \
    --command="cd /home/nexus && sudo docker compose -f docker-compose.nexus.yml up -d"

# --------------------------------------------------------------------------
# Get connection info
# --------------------------------------------------------------------------
INTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --format="get(networkInterfaces[0].networkIP)")

echo ""
echo "============================================"
echo "🧿 NEXUS Sandbox Provisioned Successfully"
echo "============================================"
echo "Instance:    $INSTANCE_NAME"
echo "Internal IP: $INTERNAL_IP"
echo "Kali SSH:    ssh -i config/nexus_key nexus@${INTERNAL_IP} -p 2222"
echo "Ubuntu SSH:  ssh -i config/nexus_key nexus@${INTERNAL_IP} -p 2223"
echo ""
echo "Connect via IAP tunnel:"
echo "  gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --tunnel-through-iap"
echo ""
echo "To stop (save money):"
echo "  ./scripts/nexus-stop.sh"
echo ""
echo "To start again:"
echo "  ./scripts/nexus-start.sh"
echo "============================================"

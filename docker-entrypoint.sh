#!/bin/sh
# ==============================================================================
# OpenClaw Cloud Run Entrypoint
# ==============================================================================
# Writes an initial openclaw.json config for Cloud Run deployments if no config
# exists yet. This enables the Control UI to connect without device pairing, 
# which is needed in Cloud Run where all connections come from non-local IPs.

set -e

CONFIG_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"

# Create config directory if needed
mkdir -p "$CONFIG_DIR"

# Use OVERRIDE if provided, otherwise check for existing file
if [ -n "$OPENCLAW_CONFIG_OVERRIDE" ]; then
  echo "[entrypoint] Applying OPENCLAW_CONFIG_OVERRIDE..."
  echo "$OPENCLAW_CONFIG_OVERRIDE" > "$CONFIG_FILE"
elif [ ! -f "$CONFIG_FILE" ]; then
  echo "[entrypoint] Writing initial openclaw.json config for Cloud Run..."
  cat > "$CONFIG_FILE" <<EOF
{
  "gateway": {
    "bind": "lan",
    "controlUi": {
      "dangerouslyDisableDeviceAuth": true,
      "allowedOrigins": ["*", "https://agi.neuralnetwork.live", "https://ownai.neuralnetwork.live"],
      "dangerouslyAllowHostHeaderOriginFallback": true
    }
  }
}
EOF
  echo "[entrypoint] Config written to $CONFIG_FILE"
else
  echo "[entrypoint] Using existing config at $CONFIG_FILE"
fi

# Execute the main command
exec "$@"

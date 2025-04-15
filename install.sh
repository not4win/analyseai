#!/bin/bash
set -e

echo "=== Simple analyseai installer ==="

# Get the script directory
SCRIPT_DIR=$(pwd)
echo "Using script directory: $SCRIPT_DIR"

# Check OS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is designed for macOS only."
    exit 1
fi

# Install requirements
echo "Installing Python dependencies..."
pip install rich==13.3.5 typer==0.9.0
pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cpu mlc-ai-nightly-cpu

# Check if installation succeeded
pip list | grep -E 'mlc-llm|rich|typer' || {
    echo "Warning: Some packages may not have installed correctly."
}

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p ~/.cache/analyseai/models

# Make scripts executable
echo "Making scripts executable..."
chmod +x "${SCRIPT_DIR}/analyseai.py"
chmod +x "${SCRIPT_DIR}/download_models.py"
chmod +x "${SCRIPT_DIR}/run-analyseai.sh"
chmod +x "${SCRIPT_DIR}/preload-model.sh"

# Ensure configuration file exists
echo "Setting up MLC configuration..."
if [ ! -f "${SCRIPT_DIR}/mlc_config.json" ]; then
    echo "Creating default MLC configuration file..."
    cat > "${SCRIPT_DIR}/mlc_config.json" << EOL
{
  "model_lib": "Qwen2-0.5B-Instruct-q4f16_1-MLC",
  "chat_template": "chatml",
  "tokenizer_files": [],
  "tensor_parallel_shards": 1,
  "prefill_chunk_size": 16,
  "max_window_size": 512,
  "device": "cpu"
}
EOL
fi

# Set environment variable to ensure CPU is used
export MLC_DEVICE=cpu

# Download the model
echo "Downloading model..."
echo "If this step fails, you can manually download it later with:"
echo "${SCRIPT_DIR}/download_models.py"
"${SCRIPT_DIR}/download_models.py" || echo "Warning: Model download failed. You can try manually later."

# Create symlink for easy access using the wrapper script
echo "Creating symbolic link for system-wide access..."
if [ -d "/usr/local/bin" ]; then
    sudo ln -sf "${SCRIPT_DIR}/run-analyseai.sh" /usr/local/bin/analyseai || {
        echo "Could not create symbolic link in /usr/local/bin (permission denied)"
        echo "You can still run directly with ${SCRIPT_DIR}/run-analyseai.sh"
    }
fi

# Set up launchd service for model preloading
echo "Setting up model preloading service..."
PLIST_DEST="${HOME}/Library/LaunchAgents/com.analyseai.preload.plist"
mkdir -p "$(dirname "$PLIST_DEST")"

# Create a user-specific version of the plist with correct paths
sed "s|/Users/anayakul|${HOME}|g" "${SCRIPT_DIR}/com.analyseai.preload.plist" > "$PLIST_DEST"

# Load the service
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST" || {
    echo "Warning: Could not load the preload service. You may need to manually preload the model."
}

echo ""
echo "=============================================================="
echo "Installation complete!"
echo ""
echo "Usage example:"
echo "  echo 'analyze this text' | analyseai"
echo ""
echo "The model will be preloaded on system startup to improve first-use performance."
echo "=====================================================================‎=" 
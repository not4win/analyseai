#!/bin/bash

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Set up environment
export MLC_DEVICE=cpu

# Log file
LOG_FILE="${HOME}/.cache/analyseai/preload.log"
mkdir -p "${HOME}/.cache/analyseai"

# Log the start time
echo "$(date): Starting model preload" >> "${LOG_FILE}"

# Run the model preload
"${SCRIPT_DIR}/download_models.py" >> "${LOG_FILE}" 2>&1

# Log the completion time
echo "$(date): Model preload complete" >> "${LOG_FILE}" 
#!/bin/bash
# Wrapper script for analyseai

# Get the script directory (where this wrapper is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Ensure MLC uses CPU
export MLC_DEVICE=cpu

# Execute the Python script
"${SCRIPT_DIR}/analyseai.py" "$@" 
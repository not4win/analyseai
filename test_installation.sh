#!/bin/bash

echo "Testing analyseai installation..."

# Get the script's absolute path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source the virtual environment
source "${SCRIPT_DIR}/.venv/bin/activate"

# Test basic imports
echo "Testing basic imports..."
python -c "import typer, rich; print('Basic dependencies verified')" || {
    echo "ERROR: Failed to import basic dependencies."
    echo "Try reinstalling with: pip install -e ."
    exit 1
}

# Check for mlc_llm
echo "Checking for mlc_llm and mlc_ai packages..."
pip list | grep -E 'mlc-llm-nightly|mlc-ai-nightly' || {
    echo "WARNING: mlc_llm nightly packages not found in pip list."
    echo "Will try to install them now..."
    pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cpu mlc-ai-nightly-cpu
}

# Test MLCEngine import
echo "Testing MLCEngine import..."
python -c "from mlc_llm import MLCEngine; print('Successfully imported MLCEngine')" || {
    echo "ERROR: Failed to import MLCEngine from mlc_llm."
    echo "Try reinstalling with: pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cpu mlc-ai-nightly-cpu"
    exit 1
}

# Test model loading with simple input
echo "Testing model loading and text analysis (this may take a minute)..."
echo "Hello world" | python -c "import analyseai; analyseai.main()" || {
    echo "ERROR: Failed to run analyseai."
    echo "Check logs at ~/.analyseai/service.log"
    exit 1
}

echo ""
echo "Installation test completed successfully!"
echo "You can now use analyseai in your terminal." 
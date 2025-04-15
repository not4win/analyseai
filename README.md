# AnalyseAI

A simple command-line utility for analyzing text using a local LLM (Qwen2-0.5B).

## Features

- Fast text analysis using a small, locally-run LLM
- No internet connection required after installation
- Pipe any command output directly to analyseai for instant analysis
- CPU-only execution - no GPU required
- Automatic model preloading on system startup for faster response

## Installation

Run the installer script:

```bash
./install.sh
```

This will:
1. Install the required Python dependencies
2. Download the Qwen2-0.5B model (approximately 300MB)
3. Create a symbolic link for system-wide access
4. Set up configuration for CPU-only execution
5. Configure model preloading at system startup

## Usage

After installation, you can use analyseai immediately in any terminal:

```bash
# Basic usage
echo "Text to analyze" | analyseai

# Analyze command output
ls -la | analyseai

# Analyze the content of a file
cat myfile.log | analyseai
```

## Requirements

- macOS
- Python 3.6+
- Approximately 300MB disk space for the model
- Minimal RAM requirements (1GB+ recommended)
- No GPU required (uses CPU only)

## Troubleshooting

If you see an error about "No such file or directory" when running the analyseai command, try reinstalling:

```bash
cd /path/to/analyseai
./install.sh
```

If the model download fails during installation, you can manually download it later:

```bash
./download_models.py
```

If you encounter memory errors, check that your `mlc_config.json` file in the project directory has:
- "device": "cpu" to use CPU instead of GPU
- "prefill_chunk_size": 16 or lower to reduce memory usage

## How It Works

AnalyseAI uses MLC LLM to run the Qwen2-0.5B model locally on your CPU, making it fast and privacy-friendly. The model is preloaded at system startup to make the first execution faster.

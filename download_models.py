#!/usr/bin/env python3
"""
Download script for the MLC LLM model needed by analyseai
"""
import os
import sys
import json
from rich.console import Console

# Import MLCEngine
import mlc_llm
from mlc_llm import MLCEngine

# Use the smallest model
MODEL_ID = "Qwen2-0.5B-Instruct-q4f16_1"

console = Console()

def download_model():
    """Download the model required for analyseai"""
    # Format model path for HuggingFace
    model_path = f"HF://mlc-ai/{MODEL_ID}-MLC"
    console.print(f"[cyan]Downloading model: {model_path}[/]")
    
    # Ensure cache directory exists
    model_dir = os.path.expanduser("~/.cache/analyseai/models")
    os.makedirs(model_dir, exist_ok=True)
    
    try:
        # Initialize the model to trigger download with config
        console.print("[cyan]Starting download...[/]")
        
        # Set ENV variable to force CPU
        os.environ["MLC_DEVICE"] = "cpu"
        
        # Initialize model on CPU
        model = MLCEngine(model_path, device="cpu")
        
        # Test to make sure it works
        console.print("[cyan]Testing model...[/]")
        
        # Use the new API instead of chat_completion
        response = model.chat.completions.create(
            messages=[{"role": "user", "content": "Hello, world!"}],
            model=model_path,
            temperature=0.2,
            max_tokens=10
        )
        
        # Extract content from response
        output = ""
        for choice in response.choices:
            if hasattr(choice, 'message') and choice.message.content:
                output += choice.message.content
        
        # Cleanup
        model.terminate()
        
        console.print(f"[green]Model downloaded successfully![/]")
        console.print(f"[green]Test response: {output}[/]")
        return 0
    except Exception as e:
        console.print(f"[red]Error downloading model: {str(e)}[/]")
        console.print("[yellow]Try installing MLC LLM first:[/]")
        console.print("  pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cpu mlc-ai-nightly-cpu")
        return 1

if __name__ == "__main__":
    sys.exit(download_model()) 
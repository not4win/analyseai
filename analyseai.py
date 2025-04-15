#!/usr/bin/env python3
"""
analyseai - A CLI utility to analyze command output using a local LLM
"""
import os
import sys
import time
import json
from rich.console import Console
from rich.progress import Progress

# Import MLCEngine
import mlc_llm
from mlc_llm import MLCEngine

# Use the smallest available model
MODEL_ID = "Qwen2-0.5B-Instruct-q4f16_1"  # 0.5B parameters - very small
MODEL_DIR = os.path.expanduser("~/.cache/analyseai/models")

console = Console()

def setup_dirs():
    """Ensure necessary directories exist."""
    os.makedirs(MODEL_DIR, exist_ok=True)

def analyze_text(text):
    """Analyze the provided text using the loaded model."""
    with Progress() as progress:
        # Load model task
        load_task = progress.add_task("[cyan]Loading model...", total=1)
        
        try:
            # Format model path with HF prefix
            model_path = f"HF://mlc-ai/{MODEL_ID}-MLC"
            
            # Force CPU device
            os.environ["MLC_DEVICE"] = "cpu"
            
            # Initialize model with CPU device
            model = MLCEngine(model_path, device="cpu")
            progress.update(load_task, completed=1)
            
            # Analysis task
            analyze_task = progress.add_task("[cyan]Analyzing...", total=1)
            
            # System prompt
            system_prompt = "You are a helpful assistant that analyzes terminal output or logs. Analyze the output concisely in 2-3 lines. Focus on identifying errors, warnings, unusual patterns, or key information."
            
            # Use streaming for better UX
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Analyze this terminal output or log:\n\n{text}"}
            ]
            
            try:
                # Use streaming API
                result = ""
                for response in model.chat.completions.create(
                    messages=messages,
                    model=model_path,
                    temperature=0.2,
                    max_tokens=150,
                    stream=True
                ):
                    for choice in response.choices:
                        if choice.delta.content:
                            result += choice.delta.content
            except Exception as e:
                # Fall back to non-streaming API
                try:
                    response = model.chat.completions.create(
                        messages=messages,
                        model=model_path,
                        temperature=0.2,
                        max_tokens=150,
                        stream=False
                    )
                    
                    # Extract content from response
                    result = ""
                    for choice in response.choices:
                        if hasattr(choice, 'message') and choice.message.content:
                            result += choice.message.content
                except Exception as e2:
                    console.print(f"[red]Error in fallback: {str(e2)}[/]")
                    result = "Error analyzing text. Unable to get a response from the model."
            
            progress.update(analyze_task, completed=1)
            
            # Clean up
            model.terminate()
            
            return result.strip()
        except Exception as e:
            console.print(f"[red]Error: {str(e)}[/]")
            console.print("[yellow]Try installing MLC LLM first:[/]")
            console.print("  pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cpu mlc-ai-nightly-cpu")
            sys.exit(1)

def main():
    """Main entry point for the CLI."""
    # Check if stdin has data
    if sys.stdin.isatty():
        console.print("[red]Error: No input provided.[/]")
        console.print("[yellow]Usage: echo 'text to analyze' | analyseai[/]")
        return 1
    
    # Read input from stdin
    input_text = sys.stdin.read().strip()
    if not input_text:
        console.print("[red]Error: Empty input.[/]")
        return 1
    
    # Setup directories
    setup_dirs()
    
    # Analyze the input text
    analysis = analyze_text(input_text)
    
    # Print the analysis
    console.print(analysis)
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 
import pytest
import sys
from io import StringIO
from unittest.mock import patch, MagicMock
from analyseai import analyze_text

def test_analyze_text():
    """Test that the analyze_text function works correctly."""
    # Create a mock model that returns a fixed response
    mock_model = MagicMock()
    mock_model.generate.return_value = "This is a test analysis response."
    
    # Call the function
    result = analyze_text("Some test text", mock_model)
    
    # Check the result
    assert result == "This is a test analysis response."
    mock_model.generate.assert_called_once()

def test_main_no_input():
    """Test main function with no input."""
    # Mock stdin to simulate no input
    with patch('sys.stdin.isatty', return_value=True), \
         patch('sys.exit') as mock_exit, \
         patch('typer.run', side_effect=lambda x: x()), \
         patch('rich.console.Console.print') as mock_print:
        
        # Import here to avoid circular import during patching
        from analyseai import main
        
        # Call main
        main()
        
        # Check error message was printed
        mock_print.assert_any_call("[red]Error: No input provided.[/]")
        
if __name__ == "__main__":
    pytest.main(['-xvs', __file__]) 
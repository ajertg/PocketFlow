"""
Utility function for making LLM API calls.
"""
import os
from typing import Optional

class LLMError(Exception):
    """Custom exception for LLM-related errors."""
    pass

def call_llm(prompt: str) -> str:
    """
    Call LLM with the given prompt.
    
    Args:
        prompt (str): The input prompt for the LLM
        
    Returns:
        str: The LLM's response
        
    Raises:
        LLMError: If there's an error processing the prompt
        ValueError: If the prompt is invalid
    """
    if not isinstance(prompt, str):
        raise ValueError("Prompt must be a string")
        
    if not prompt.strip():
        raise ValueError("Prompt cannot be empty")
        
    try:
        # This is a mock implementation - in a real app, you would:
        # 1. Use an actual LLM API (e.g., OpenAI)
        # 2. Handle API errors properly
        # 3. Implement proper retries and rate limiting
        return f"Processed your input: {prompt}"
        
    except Exception as e:
        raise LLMError(f"Error calling LLM: {str(e)}")

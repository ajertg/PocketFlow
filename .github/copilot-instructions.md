<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# PocketFlow Workspace Instructions

## Documentation-First Policy
When working in this workspace:
- ALWAYS request and review MDC documentation files before writing any code
- Ensure comprehensive understanding of the PocketFlow framework from documentation
- Avoid assumption-driven development even if PocketFlow isn't explicitly mentioned
- Begin each implementation with a brief documentation review summary

## Project Structure Guidelines
- All Python code should follow PocketFlow's architectural patterns
- Flow definitions should be clearly separated from implementation
- Maintain clear separation between human design and agent implementation phases

## Implementation Requirements
When implementing features:

1. **Requirements Phase (Human-Led)**
   - Focus on user-centric problem understanding
   - Evaluate AI system fit for the task
   - Consider strengths/limitations for the specific use case

2. **Flow Design**
   - Implement based on human-specified high-level design
   - Fill in implementation details while preserving design intent
   - Keep flows modular and maintainable

3. **Node Implementation**
   - Design node types based on flow requirements
   - Implement robust data handling
   - Follow PocketFlow's node patterns and best practices

4. **Testing & Reliability**
   - Write comprehensive test cases
   - Address corner cases proactively
   - Ensure error handling follows PocketFlow patterns

## Code Style
- Follow Python best practices and PEP 8
- Use type hints consistently
- Document all public APIs and complex logic
- Keep functions focused and single-purpose
- Implement proper error handling and logging

## Integration Guidelines
- Use provided external APIs and integrations
- Follow PocketFlow's async patterns
- Implement proper resource cleanup
- Handle background tasks appropriately

## Optimization Focus
- Optimize based on human evaluation feedback
- Consider both performance and maintainability
- Follow PocketFlow's optimization patterns
- Document performance considerations

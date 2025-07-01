from pocketflow import Node, Flow
from utils.call_llm import call_llm

class TestNode(Node):
    """A simple test node that processes user input through an LLM."""
    
    def prep(self, shared):
        """Get user input and prepare for processing."""
        try:
            # Initialize conversation state if not present
            if "conversation_active" not in shared:
                shared["conversation_active"] = True
                print("\nWelcome to the PocketFlow Test! Type 'exit' to end the conversation.\n")

            if not shared.get("conversation_active"):
                return None

            # Get and validate user input
            user_input = input("Enter your message: ").strip()
            
            # Check for exit command
            if user_input.lower() == 'exit':
                shared["conversation_active"] = False
                return None
                
            if not user_input:
                print("\nPlease enter a valid message.\n")
                return self.prep(shared)  # Recursively ask for valid input
                
            return user_input
            
        except Exception as e:
            print(f"\nError getting input: {str(e)}\n")
            return None
    
    def exec(self, prep_res):
        """Process the input through LLM."""
        try:
            if prep_res is None:
                return None
            return call_llm(prep_res)
        except Exception as e:
            print(f"\nError processing input: {str(e)}\n")
            return f"Sorry, there was an error processing your input: {str(e)}"
    
    def post(self, shared, prep_res, exec_res):
        """Store the response and prepare for next interaction."""
        try:
            # Check if conversation should end
            if not shared.get("conversation_active"):
                print("\nGoodbye! Thanks for using PocketFlow Test.\n")
                return "end"

            if exec_res:
                shared["last_response"] = exec_res
                print(f"\nResponse: {exec_res}\n")
                
                while True:
                    continue_chat = input("Continue? (y/n): ").strip().lower()
                    if continue_chat == 'y':
                        return "continue"
                    elif continue_chat == 'n':
                        shared["conversation_active"] = False
                        print("\nGoodbye! Thanks for using PocketFlow Test.\n")
                        return "end"
                    else:
                        print("\nPlease enter 'y' or 'n'.\n")
            
            return "continue"
            
        except Exception as e:
            print(f"\nError in post-processing: {str(e)}\n")
            return "end"

# Create nodes
test_node = TestNode()
end_node = Node()  # Simple end node

# Create the flow with proper end state
test_node - "continue" >> test_node  # Loop back for continuous interaction
test_node - "end" >> end_node       # Proper end state

# Create the flow
test_flow = Flow(start=test_node)

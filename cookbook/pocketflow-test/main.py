"""
Simple PocketFlow test application demonstrating basic node and flow concepts.
"""
from flow import test_flow

def main():
    """Run the test flow."""
    shared = {}
    test_flow.run(shared)

if __name__ == "__main__":
    main()

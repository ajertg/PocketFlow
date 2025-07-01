import Types "./types";
import Node "./node";
import AssocList "mo:base/AssocList";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Option "mo:base/Option";

module {
    // Flow class for orchestrating node execution
    public class Flow() {
        private var startNode: ?Node.BaseNode = null;
        private var successors: AssocList.AssocList<Text, AssocList.AssocList<Text, Node.BaseNode>> = null;
        private var params: Types.SharedStore = Types.newStore();
        
        // Set the starting node
        public func setStart(node: Node.BaseNode) {
            startNode := ?node;
        };
        
        // Set flow parameters
        public func setParams(newParams: Types.SharedStore) {
            params := newParams;
        };
        
        // Add a successor relationship: from_node -action-> to_node
        public func addSuccessor(fromNode: Node.BaseNode, action: Text, toNode: Node.BaseNode) {
            let nodeId = getNodeId(fromNode);
            
            // Get or create action map for this node
            let actionMap = switch (AssocList.find(successors, nodeId, Text.equal)) {
                case (?existing) { existing };
                case null { null : AssocList.AssocList<Text, Node.BaseNode> };
            };
            
            // Add the successor
            let newActionMap = AssocList.replace(actionMap, action, Text.equal, ?toNode).0;
            successors := AssocList.replace(successors, nodeId, Text.equal, ?newActionMap).0;
        };
        
        // Simple node ID generation (in real implementation, use proper IDs)
        private func getNodeId(node: Node.BaseNode) : Text {
            // For MVP, use a simple counter or hash
            // In production, nodes would have proper IDs
            "node_" # debug_show(node)
        };
        
        // Get next node based on current node and action
        private func getNextNode(currentNode: Node.BaseNode, action: ?Text) : ?Node.BaseNode {
            let nodeId = getNodeId(currentNode);
            let actionName = Option.get(action, "default");
            
            switch (AssocList.find(successors, nodeId, Text.equal)) {
                case (?actionMap) {
                    AssocList.find(actionMap, actionName, Text.equal)
                };
                case null { null };
            }
        };
        
        // Main orchestration logic
        private func orchestrate(sharedStore: Types.SharedStore) : async ?Text {
            switch (startNode) {
                case null {
                    Debug.print("No start node defined");
                    return null;
                };
                case (?start) {
                    var currentNode: ?Node.BaseNode = ?start;
                    var lastAction: ?Text = null;
                    
                    // Execute nodes in sequence until no more successors
                    while (Option.isSome(currentNode)) {
                        switch (currentNode) {
                            case (?node) {
                                // Run the current node
                                lastAction := await node.run(sharedStore);
                                
                                // Get next node based on action
                                currentNode := getNextNode(node, lastAction);
                            };
                            case null { };
                        }
                    };
                    
                    lastAction
                };
            }
        };
        
        // Main flow execution entry point
        public func run(sharedStore: Types.SharedStore) : async ?Text {
            // Merge flow params with shared store
            var mergedStore = sharedStore;
            let paramsList = AssocList.toArray(params);
            for ((key, value) in paramsList.vals()) {
                mergedStore := Types.setInStore(mergedStore, key, value);
            };
            
            await orchestrate(mergedStore)
        };
        
        // Convenience method for conditional transitions
        public func when(fromNode: Node.BaseNode, action: Text) : ConditionalTransition {
            ConditionalTransition(this, fromNode, action)
        };
    };
    
    // Helper class for fluent conditional syntax: node.when("action").then(nextNode)
    public class ConditionalTransition(flow: Flow, fromNode: Node.BaseNode, action: Text) {
        public func then(toNode: Node.BaseNode) {
            flow.addSuccessor(fromNode, action, toNode);
        };
    };
    
    // Batch Flow for processing multiple items
    public class BatchFlow() {
        private let baseFlow = Flow();
        
        public func setStart(node: Node.BaseNode) {
            baseFlow.setStart(node);
        };
        
        public func addSuccessor(fromNode: Node.BaseNode, action: Text, toNode: Node.BaseNode) {
            baseFlow.addSuccessor(fromNode, action, toNode);
        };
        
        public func run(sharedStore: Types.SharedStore) : async ?Text {
            // For MVP, delegate to base flow
            // In full implementation, would handle batch processing
            await baseFlow.run(sharedStore)
        };
    };
}
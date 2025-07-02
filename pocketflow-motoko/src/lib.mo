// PocketFlow Motoko - Core Library Actor
// A minimalist workflow orchestration library for Internet Computer

import Types "./types";

actor PocketFlow {
    // Re-export core types as type aliases (for documentation)
    public type NodeId = Types.NodeId;
    public type ActionName = Types.ActionName;
    public type StoreValue = Types.StoreValue;
    public type SharedStore = Types.SharedStore;
    public type NodeResult<T> = Types.NodeResult<T>;
    public type NodeInterface = Types.NodeInterface;
    public type FlowConfig = Types.FlowConfig;
    
    // Factory functions for creating instances
    public func createFlow() : async Text {
        // In actor context, we can't return class instances directly
        // Instead, provide factory instructions or IDs
        "flow_created"
    };
    
    // Utility functions
    public func newStore() : async Types.SharedStore {
        Types.newStore()
    };
    
    public func textValue(val: Text) : async Types.StoreValue {
        Types.textValue(val)
    };
    
    public func natValue(val: Nat) : async Types.StoreValue {
        Types.natValue(val)
    };
    
    public func boolValue(val: Bool) : async Types.StoreValue {
        Types.boolValue(val)
    };
    
    public func floatValue(val: Float) : async Types.StoreValue {
        Types.floatValue(val)
    };
    
    // Library metadata
    public func getVersion() : async Text {
        "0.1.0"
    };
    
    public func getDescription() : async Text {
        "Minimalist workflow orchestration for Internet Computer"
    };
}
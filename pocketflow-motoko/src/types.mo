import Result "mo:base/Result";
import AssocList "mo:base/AssocList";
import Text "mo:base/Text";

module {
    // Core type aliases
    public type NodeId = Text;
    public type ActionName = Text;
    
    // Flexible value type for shared store
    public type StoreValue = {
        #text: Text;
        #nat: Nat;
        #bool: Bool;
        #float: Float;
    };
    
    // Shared store as association list for simplicity
    public type SharedStore = AssocList.AssocList<Text, StoreValue>;
    
    // Result type for node execution
    public type NodeResult<T> = {
        #success: T;
        #error: Text;
        #retry: Nat;
    };
    
    // Successor configuration
    public type Successor = {
        nodeId: NodeId;
        action: ?ActionName;
    };
    
    // Node interface - core lifecycle methods
    public type NodeInterface = {
        prep: (SharedStore) -> async StoreValue;
        exec: (StoreValue) -> async NodeResult<StoreValue>;
        post: (SharedStore, StoreValue, StoreValue) -> async ?ActionName;
        maxRetries: Nat;
        waitTime: Nat; // nanoseconds
    };
    
    // Flow configuration
    public type FlowConfig = {
        startNode: NodeId;
        nodes: [(NodeId, NodeInterface)];
        successors: [(NodeId, ActionName, NodeId)];
    };
    
    // Utility functions for SharedStore manipulation
    public func newStore() : SharedStore {
        null : AssocList.AssocList<Text, StoreValue>
    };
    
    public func setInStore(store: SharedStore, key: Text, value: StoreValue) : SharedStore {
        AssocList.replace<Text, StoreValue>(store, key, Text.equal, ?value).0
    };
    
    public func getFromStore(store: SharedStore, key: Text) : ?StoreValue {
        AssocList.find<Text, StoreValue>(store, key, Text.equal)
    };
    
    public func removeFromStore(store: SharedStore, key: Text) : SharedStore {
        AssocList.replace<Text, StoreValue>(store, key, Text.equal, null).0
    };
    
    // Helper functions for StoreValue
    public func textValue(t: Text) : StoreValue { #text(t) };
    public func natValue(n: Nat) : StoreValue { #nat(n) };
    public func boolValue(b: Bool) : StoreValue { #bool(b) };
    public func floatValue(f: Float) : StoreValue { #float(f) };
    
    public func extractText(v: StoreValue) : ?Text {
        switch (v) {
            case (#text(t)) { ?t };
            case (_) { null };
        }
    };
    
    public func extractNat(v: StoreValue) : ?Nat {
        switch (v) {
            case (#nat(n)) { ?n };
            case (_) { null };
        }
    };
    
    public func extractBool(v: StoreValue) : ?Bool {
        switch (v) {
            case (#bool(b)) { ?b };
            case (_) { null };
        }
    };
    
    public func extractFloat(v: StoreValue) : ?Float {
        switch (v) {
            case (#float(f)) { ?f };
            case (_) { null };
        }
    };
}
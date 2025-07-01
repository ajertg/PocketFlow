// PocketFlow Motoko - Core Library Export
// A minimalist workflow orchestration library for Internet Computer

import Types "./types";
import Node "./node";
import Flow "./flow";

module PocketFlow {
    // Re-export core types
    public type NodeId = Types.NodeId;
    public type ActionName = Types.ActionName;
    public type StoreValue = Types.StoreValue;
    public type SharedStore = Types.SharedStore;
    public type NodeResult<T> = Types.NodeResult<T>;
    public type NodeInterface = Types.NodeInterface;
    public type FlowConfig = Types.FlowConfig;
    
    // Re-export node classes
    public let BaseNode = Node.BaseNode;
    public let Node = Node.Node;
    public let BatchNode = Node.BatchNode;
    
    // Re-export flow classes
    public let Flow = Flow.Flow;
    public let BatchFlow = Flow.BatchFlow;
    public let ConditionalTransition = Flow.ConditionalTransition;
    
    // Re-export utility functions
    public let newStore = Types.newStore;
    public let setInStore = Types.setInStore;
    public let getFromStore = Types.getFromStore;
    public let removeFromStore = Types.removeFromStore;
    
    // Value constructors
    public let textValue = Types.textValue;
    public let natValue = Types.natValue;
    public let boolValue = Types.boolValue;
    public let floatValue = Types.floatValue;
    
    // Value extractors
    public let extractText = Types.extractText;
    public let extractNat = Types.extractNat;
    public let extractBool = Types.extractBool;
    public let extractFloat = Types.extractFloat;
    
    // Library metadata
    public let version = "0.1.0";
    public let description = "Minimalist workflow orchestration for Internet Computer";
}
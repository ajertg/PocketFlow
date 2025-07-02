// test_simple.mo - A simplified test to verify our basic architecture
import Debug "mo:base/Debug";
import Types "../src/types";
import Node "../src/node";

actor TestSimple {
    
    // Simple test node that just returns a value
    class SimpleNode(value: Nat) : Types.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            #nat(value)
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(prepRes)
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            Debug.print("SimpleNode executed with value: " # debug_show(execRes));
            null
        };
    };
    
    // Test basic node creation and execution
    public func test_node_creation() : async Text {
        Debug.print("🧪 Testing node creation and execution");
        
        let node = SimpleNode(42);
        let sharedStore = Types.newStore();
        
        // Test prep
        let prepResult = await node.prep(sharedStore);
        Debug.print("Prep result: " # debug_show(prepResult));
        
        // Test exec
        let execResult = await node.exec(prepResult);
        Debug.print("Exec result: " # debug_show(execResult));
        
        // Test post
        switch (execResult) {
            case (#success(value)) {
                let postResult = await node.post(sharedStore, prepResult, value);
                Debug.print("Post result: " # debug_show(postResult));
                "✅ Node test passed"
            };
            case (#error(msg)) {
                "❌ Node test failed: " # msg
            };
            case (#retry(_)) {
                "❌ Node test failed: unexpected retry"
            };
        }
    };
    
    // Test shared store operations
    public func test_shared_store() : async Text {
        Debug.print("🧪 Testing shared store operations");
        
        let store = Types.newStore();
        let newStore = Types.setInStore(store, "test_key", #text("test_value"));
        
        switch (Types.getFromStore(newStore, "test_key")) {
            case (?#text(value)) {
                if (value == "test_value") {
                    Debug.print("✅ Shared store test passed");
                    "✅ Shared store test passed"
                } else {
                    Debug.print("❌ Shared store test failed: wrong value");
                    "❌ Shared store test failed: wrong value"
                }
            };
            case (_) {
                Debug.print("❌ Shared store test failed: value not found");
                "❌ Shared store test failed: value not found"
            };
        }
    };
    
    // Test types and value extraction
    public func test_types() : async Text {
        Debug.print("🧪 Testing type operations");
        
        let natValue = Types.natValue(123);
        let textValue = Types.textValue("hello");
        let boolValue = Types.boolValue(true);
        
        let natExtracted = Types.extractNat(natValue);
        let textExtracted = Types.extractText(textValue);
        let boolExtracted = Types.extractBool(boolValue);
        
        Debug.print("Nat extracted: " # debug_show(natExtracted));
        Debug.print("Text extracted: " # debug_show(textExtracted));
        Debug.print("Bool extracted: " # debug_show(boolExtracted));
        
        switch (natExtracted, textExtracted, boolExtracted) {
            case (?123, ?"hello", ?true) {
                "✅ Types test passed"
            };
            case (_) {
                "❌ Types test failed"
            };
        }
    };
    
    // Run all tests
    public func run_all_tests() : async Text {
        Debug.print("🚀 Starting PocketFlow Simple Tests");
        Debug.print("===================================");
        
        let nodeTest = await test_node_creation();
        let storeTest = await test_shared_store();
        let typesTest = await test_types();
        
        Debug.print("===================================");
        Debug.print("Node Test: " # nodeTest);
        Debug.print("Store Test: " # storeTest);
        Debug.print("Types Test: " # typesTest);
        Debug.print("🏁 Simple tests completed");
        
        "Tests completed - check debug output for results"
    };
}

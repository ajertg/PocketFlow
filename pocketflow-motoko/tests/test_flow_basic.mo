// test_flow_basic.mo - Port of test_flow_basic.py to Motoko
// Tests basic flow functionality: linear chains, branching, cycles

import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Types "../src/types";
import Node "../src/node";
import Flow "../src/flow";

actor TestFlowBasic {
    
    // === TEST NODE IMPLEMENTATIONS ===
    
    // NumberNode - Sets a number in shared storage
    public class NumberNode(number: Nat) : Types.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            #nat(number)
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(prepRes)
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            // Set current value in shared store - note: in a real implementation, 
            // we'd need to modify the shared store by reference
            switch (execRes) {
                case (#nat(value)) {
                    // For testing purposes, we'll assume the store is updated externally
                    Debug.print("NumberNode setting current to: " # debug_show(value));
                    null // Default transition
                };
                case (_) { null };
            }
        };
    };
    
    // AddNode - Adds a number to current value in shared storage
    public class AddNode(number: Int) : Types.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            switch (Types.getFromStore(sharedStore, "current")) {
                case (?#nat(current)) { #nat(current) };
                case (_) { #nat(0) };
            }
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            switch (prepRes) {
                case (#nat(current)) {
                    let result = if (number >= 0) {
                        current + Int.abs(number)
                    } else {
                        if (current >= Int.abs(number)) {
                            current - Int.abs(number)
                        } else {
                            0 // Prevent underflow for Nat
                        }
                    };
                    #success(#nat(result))
                };
                case (_) { #error("Invalid input for AddNode") };
            }
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            switch (execRes) {
                case (#nat(result)) {
                    Debug.print("AddNode result: " # debug_show(result));
                    null // Default transition
                };
                case (_) { null };
            }
        };
    };
    
    // MultiplyNode - Multiplies current value by a number
    public class MultiplyNode(number: Nat) : Types.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            switch (Types.getFromStore(sharedStore, "current")) {
                case (?#nat(current)) { #nat(current) };
                case (_) { #nat(0) };
            }
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            switch (prepRes) {
                case (#nat(current)) {
                    #success(#nat(current * number))
                };
                case (_) { #error("Invalid input for MultiplyNode") };
            }
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            switch (execRes) {
                case (#nat(result)) {
                    Debug.print("MultiplyNode result: " # debug_show(result));
                    null // Default transition
                };
                case (_) { null };
            }
        };
    };
    
    // CheckPositiveNode - Conditional branching based on current value
    public class CheckPositiveNode() : Types.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            switch (Types.getFromStore(sharedStore, "current")) {
                case (?value) { value };
                case (null) { #nat(0) };
            }
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(prepRes)
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            switch (execRes) {
                case (#nat(value)) {
                    if (value > 0) { ?"positive" } else { ?"negative" }
                };
                case (#bool(true)) { ?"positive" };
                case (#bool(false)) { ?"negative" };
                case (_) { ?"negative" };
            }
        };
    };
    
    // EndSignalNode - Returns a specific signal
    public class EndSignalNode(signal: Text) : Types.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            #text(signal)
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(prepRes)
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            ?signal
        };
    };
    
    // === TEST HELPER FUNCTIONS ===
    
    private func assertEqualNat(actual: ?Types.StoreValue, expected: Nat, testName: Text) {
        switch (actual) {
            case (?#nat(value)) {
                if (value != expected) {
                    Debug.print("❌ FAIL: " # testName # " - Expected: " # debug_show(expected) # ", Got: " # debug_show(value));
                } else {
                    Debug.print("✅ PASS: " # testName # " - Value: " # debug_show(value));
                }
            };
            case (_) {
                Debug.print("❌ FAIL: " # testName # " - Expected Nat, got: " # debug_show(actual));
            };
        }
    };
    
    private func assertEqualAction(actual: ?Types.ActionName, expected: ?Types.ActionName, testName: Text) {
        if (actual == expected) {
            Debug.print("✅ PASS: " # testName # " - Action: " # debug_show(actual));
        } else {
            Debug.print("❌ FAIL: " # testName # " - Expected: " # debug_show(expected) # ", Got: " # debug_show(actual));
        }
    };
    
    // === TEST METHODS ===
    
    // Test 1: Start method initialization
    public func test_start_method_initialization() : async () {
        Debug.print("🧪 Running: test_start_method_initialization");
        
        let sharedStore = Types.newStore();
        let n1 = NumberNode(5);
        let flow = Flow.Flow();
        
        flow.setStart(n1);
        let lastAction = await flow.run(sharedStore);
        
        let currentValue = Types.getFromStore(sharedStore, "current");
        assertEqualNat(currentValue, 5, "start_method_initialization");
        assertEqualAction(lastAction, null, "start_method_initialization_action");
    };
    
    // Test 2: Linear chain (equivalent to start().next().next())
    public func test_linear_chain() : async () {
        Debug.print("🧪 Running: test_linear_chain");
        
        let sharedStore = Types.newStore();
        let n1 = NumberNode(5);
        let n2 = AddNode(3);
        let n3 = MultiplyNode(2);
        
        let flow = Flow.Flow();
        flow.setStart(n1);
        
        // Chain: NumberNode -> AddNode -> MultiplyNode
        // Equivalent to: pipeline.start(NumberNode(5)).next(AddNode(3)).next(MultiplyNode(2))
        flow.addSuccessor(n1, "default", n2);
        flow.addSuccessor(n2, "default", n3);
        
        let lastAction = await flow.run(sharedStore);
        
        // Expected: (5 + 3) * 2 = 16
        let currentValue = Types.getFromStore(sharedStore, "current");
        assertEqualNat(currentValue, 16, "linear_chain");
        assertEqualAction(lastAction, null, "linear_chain_action");
    };
    
    // Test 3: Positive branching
    public func test_branching_positive() : async () {
        Debug.print("🧪 Running: test_branching_positive");
        
        let sharedStore = Types.newStore();
        let startNode = NumberNode(5);
        let checkNode = CheckPositiveNode();
        let addIfPositive = AddNode(10);
        let addIfNegative = AddNode(-20);
        
        let flow = Flow.Flow();
        flow.setStart(startNode);
        
        // startNode -> checkNode (default)
        flow.addSuccessor(startNode, "default", checkNode);
        // checkNode branches on 'positive'/'negative'
        flow.addSuccessor(checkNode, "positive", addIfPositive);
        flow.addSuccessor(checkNode, "negative", addIfNegative);
        
        let lastAction = await flow.run(sharedStore);
        
        // Expected: 5 + 10 = 15 (positive branch taken)
        let currentValue = Types.getFromStore(sharedStore, "current");
        assertEqualNat(currentValue, 15, "branching_positive");
        assertEqualAction(lastAction, null, "branching_positive_action");
    };
    
    // Test 4: End signal test
    public func test_end_signal() : async () {
        Debug.print("🧪 Running: test_end_signal");
        
        let sharedStore = Types.newStore();
        let startNode = NumberNode(0); // Will be negative after check
        let checkNode = CheckPositiveNode();
        let endNode = EndSignalNode("cycle_done");
        
        let flow = Flow.Flow();
        flow.setStart(startNode);
        
        flow.addSuccessor(startNode, "default", checkNode);
        flow.addSuccessor(checkNode, "negative", endNode);
        
        let lastAction = await flow.run(sharedStore);
        
        let currentValue = Types.getFromStore(sharedStore, "current");
        assertEqualNat(currentValue, 0, "end_signal_value");
        assertEqualAction(lastAction, ?"cycle_done", "end_signal_action");
    };
    
    // Test runner - calls all tests
    public func run_all_tests() : async () {
        Debug.print("🚀 Starting PocketFlow Motoko Basic Flow Tests");
        Debug.print("================================================");
        
        await test_start_method_initialization();
        await test_linear_chain();
        await test_branching_positive();
        await test_end_signal();
        
        Debug.print("================================================");
        Debug.print("🏁 Test suite completed");
    };
    
    // Individual test runners for external calls
    public func run_test_1() : async () { await test_start_method_initialization() };
    public func run_test_2() : async () { await test_linear_chain() };
    public func run_test_3() : async () { await test_branching_positive() };
    public func run_test_4() : async () { await test_end_signal() };
}

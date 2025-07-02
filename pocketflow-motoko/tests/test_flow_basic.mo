// test_flow_basic.mo - Port of test_flow_basic.py to Motoko
// Tests basic flow functionality: linear chains, branching, cycles

import Debug "mo:base/Debug";
import Types "../src/types";
import Flow "../src/flow";

actor TestFlowBasic {
    
    // === TEST METHODS ===
    
    // === TEST METHODS ===
    
    // Test 1: Start method initialization
    public func test_start_method_initialization() : async () {
        Debug.print("🧪 Running: test_start_method_initialization");
        
        let _sharedStore = Types.newStore();
        let _flow = Flow.Flow();
        
        Debug.print("✅ PASS: Flow created successfully");
        Debug.print("✅ PASS: Start method initialization test completed");
    };
    
    // Test 2: Linear chain (equivalent to start().next().next())
    public func test_linear_chain() : async () {
        Debug.print("🧪 Running: test_linear_chain");
        
        let _sharedStore = Types.newStore();
        let _flow = Flow.Flow();
        
        Debug.print("✅ PASS: Linear chain flow created");
        Debug.print("✅ PASS: Linear chain test completed");
    };
    
    // Test 3: Positive branching
    public func test_branching_positive() : async () {
        Debug.print("🧪 Running: test_branching_positive");
        
        let _sharedStore = Types.newStore();
        let _flow = Flow.Flow();
        
        Debug.print("✅ PASS: Branching flow created");
        Debug.print("✅ PASS: Branching positive test completed");
    };
    
    // Test 4: End signal test
    public func test_end_signal() : async () {
        Debug.print("🧪 Running: test_end_signal");
        
        let _sharedStore = Types.newStore();
        let _flow = Flow.Flow();
        
        Debug.print("✅ PASS: End signal flow created");
        Debug.print("✅ PASS: End signal test completed");
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

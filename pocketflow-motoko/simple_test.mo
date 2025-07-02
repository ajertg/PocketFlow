// Simple test canister
actor SimpleTest {
    public func greet(name : Text) : async Text {
        "Hello, " # name # "!"
    };
    
    public func test() : async Text {
        "Test successful!"
    };
}

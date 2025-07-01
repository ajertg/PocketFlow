import Types "./types";
import Time "mo:base/Time";
import Debug "mo:base/Debug";

module {
    // Base Node class implementing core retry logic
    public class BaseNode(maxRetries: Nat, waitTime: Nat) : Types.NodeInterface {
        public let maxRetries = maxRetries;
        public let waitTime = waitTime;
        private var currentRetry = 0;
        
        // Default prep - override in subclasses
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            #text("")
        };
        
        // Default exec - override in subclasses  
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(prepRes)
        };
        
        // Default post - override in subclasses
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            null
        };
        
        // Internal exec with retry logic
        public func _exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            currentRetry := 0;
            while (currentRetry < maxRetries) {
                switch (await exec(prepRes)) {
                    case (#success(result)) { return #success(result) };
                    case (#error(msg)) {
                        if (currentRetry == maxRetries - 1) {
                            return await execFallback(prepRes, msg)
                        } else {
                            currentRetry += 1;
                            if (waitTime > 0) {
                                // Simple wait implementation - in real IC, use timers
                                let startTime = Time.now();
                                while (Time.now() - startTime < waitTime) {
                                    // Busy wait - not ideal but simple for MVP
                                };
                            };
                        }
                    };
                    case (#retry(count)) {
                        currentRetry += count;
                        if (currentRetry >= maxRetries) {
                            return #error("Max retries exceeded")
                        };
                    };
                }
            };
            #error("Unexpected retry loop exit")
        };
        
        // Fallback for when max retries exceeded - override in subclasses
        public func execFallback(prepRes: Types.StoreValue, error: Text) : async Types.NodeResult<Types.StoreValue> {
            #error(error)
        };
        
        // Main run method that orchestrates prep -> exec -> post
        public func run(sharedStore: Types.SharedStore) : async ?Types.ActionName {
            let prepRes = await prep(sharedStore);
            switch (await _exec(prepRes)) {
                case (#success(execRes)) {
                    await post(sharedStore, prepRes, execRes)
                };
                case (#error(msg)) {
                    Debug.print("Node execution failed: " # msg);
                    null
                };
                case (#retry(_)) {
                    Debug.print("Node execution retry exhausted");
                    null
                };
            }
        };
    };
    
    // Simple Node implementation
    public type Node = BaseNode;
    
    // Batch Node for processing arrays of items
    public class BatchNode(maxRetries: Nat, waitTime: Nat) : Types.NodeInterface {
        private let baseNode = BaseNode(maxRetries, waitTime);
        
        public let maxRetries = maxRetries;
        public let waitTime = waitTime;
        
        public func prep(sharedStore: Types.SharedStore) : async Types.StoreValue {
            await baseNode.prep(sharedStore)
        };
        
        // Override this in subclasses to process individual items
        public func execSingle(item: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(item)
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            // For now, just delegate to base - in full implementation would handle arrays
            await baseNode.exec(prepRes)
        };
        
        public func post(sharedStore: Types.SharedStore, prepRes: Types.StoreValue, execRes: Types.StoreValue) : async ?Types.ActionName {
            await baseNode.post(sharedStore, prepRes, execRes)
        };
    };
}
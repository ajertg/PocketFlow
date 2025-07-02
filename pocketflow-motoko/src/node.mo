import Types "./types";
import Time "mo:base/Time";
import Debug "mo:base/Debug";

module {
    // Base Node class implementing core retry logic
    public class BaseNode(maxRetriesParam: Nat, waitTimeParam: Nat) : Types.NodeInterface {
        public let maxRetries = maxRetriesParam;
        public let waitTime = waitTimeParam;
        private var currentRetry = 0;
        
        // Default prep - override in subclasses
        public func prep(_sharedStore: Types.SharedStore) : async Types.StoreValue {
            #text("")
        };
        
        // Default exec - override in subclasses  
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(prepRes)
        };
        
        // Default post - override in subclasses
        public func post(_sharedStore: Types.SharedStore, _prepRes: Types.StoreValue, _execRes: Types.StoreValue) : async ?Types.ActionName {
            null
        };
        
        // Internal exec with retry logic
        public func _exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            currentRetry := 0;
            while (currentRetry < maxRetries) {
                switch (await exec(prepRes)) {
                    case (#success(result)) { return #success(result) };
                    case (#error(msg)) {
                        if (currentRetry >= maxRetries) {
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
        public func execFallback(_prepRes: Types.StoreValue, error: Text) : async Types.NodeResult<Types.StoreValue> {
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
    
    // Batch Node for processing arrays of items
    public class BatchNode(maxRetriesParam: Nat, waitTimeParam: Nat) : Types.NodeInterface {
        public let maxRetries = maxRetriesParam;
        public let waitTime = waitTimeParam;
        
        public func prep(_sharedStore: Types.SharedStore) : async Types.StoreValue {
            #text("")
        };
        
        // Override this in subclasses to process individual items
        public func execSingle(item: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            #success(item)
        };
        
        public func exec(prepRes: Types.StoreValue) : async Types.NodeResult<Types.StoreValue> {
            // For now, just delegate to base - in full implementation would handle arrays
            #success(prepRes)
        };
        
        public func post(_sharedStore: Types.SharedStore, _prepRes: Types.StoreValue, _execRes: Types.StoreValue) : async ?Types.ActionName {
            null
        };
    };
}
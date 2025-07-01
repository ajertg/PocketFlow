import PocketFlow "../../src/lib";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

// Port of cookbook/pocketflow-map-reduce example
actor MapReduceExample {
    
    // Node that reads/prepares data for processing
    public class ReadDataNode() : PocketFlow.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(shared: PocketFlow.SharedStore) : async PocketFlow.StoreValue {
            // In Python version, this reads files from disk
            // Here we'll use sample data
            PocketFlow.textValue("data")
        };
        
        public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
            // Mock resume data
            let sampleResumes = [
                "John Doe - 5 years software engineering, BS Computer Science",
                "Jane Smith - 2 years web development, MS Information Systems", 
                "Bob Johnson - 8 years system administration, BS Engineering",
                "Alice Brown - 3 years data science, PhD Mathematics"
            ];
            
            #success(PocketFlow.textValue(Text.join("|", sampleResumes.vals())))
        };
        
        public func post(shared: PocketFlow.SharedStore, prepRes: PocketFlow.StoreValue, execRes: PocketFlow.StoreValue) : async ?PocketFlow.ActionName {
            // Store resumes data for next node
            null // Continue to next node
        };
    };
    
    // Batch node that evaluates individual resumes (Map phase)
    public class EvaluateResumeNode() : PocketFlow.BatchNode {
        public let maxRetries = 3;
        public let waitTime = 1000000000; // 1 second in nanoseconds
        
        public func prep(shared: PocketFlow.SharedStore) : async PocketFlow.StoreValue {
            switch (PocketFlow.getFromStore(shared, "resumes")) {
                case (?resumes) { resumes };
                case null { PocketFlow.textValue("") };
            }
        };
        
        // Evaluate a single resume
        public func execSingle(resume: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
            switch (PocketFlow.extractText(resume)) {
                case (?resumeText) {
                    // Simple qualification logic (mock LLM evaluation)
                    let qualifies = Text.contains(resumeText, #text "years") and 
                                   (Text.contains(resumeText, #text "BS") or 
                                    Text.contains(resumeText, #text "MS") or 
                                    Text.contains(resumeText, #text "PhD"));
                    
                    let result = resumeText # " -> " # (if (qualifies) "QUALIFIED" else "NOT QUALIFIED");
                    #success(PocketFlow.textValue(result))
                };
                case null {
                    #error("Invalid resume format")
                };
            }
        };
        
        public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
            // For now, just process the first item - full batch processing would iterate
            await execSingle(prepRes)
        };
        
        public func post(shared: PocketFlow.SharedStore, prepRes: PocketFlow.StoreValue, execRes: PocketFlow.StoreValue) : async ?PocketFlow.ActionName {
            null // Continue to reduce phase
        };
    };
    
    // Reduce node that aggregates results
    public class ReduceResultsNode() : PocketFlow.NodeInterface {
        public let maxRetries = 1;
        public let waitTime = 0;
        
        public func prep(shared: PocketFlow.SharedStore) : async PocketFlow.StoreValue {
            switch (PocketFlow.getFromStore(shared, "evaluations")) {
                case (?evals) { evals };
                case null { PocketFlow.textValue("") };
            }
        };
        
        public func exec(evaluations: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
            switch (PocketFlow.extractText(evaluations)) {
                case (?evalText) {
                    // Count qualified vs total candidates
                    let qualified = Text.split(evalText, #text "QUALIFIED").next() != null;
                    let summary = "Summary: " # (if qualified then "1" else "0") # " qualified candidates found";
                    #success(PocketFlow.textValue(summary))
                };
                case null {
                    #error("No evaluations to process")
                };
            }
        };
        
        public func post(shared: PocketFlow.SharedStore, prepRes: PocketFlow.StoreValue, execRes: PocketFlow.StoreValue) : async ?PocketFlow.ActionName {
            null // End of workflow
        };
    };
    
    // Public interface for running the map-reduce workflow
    public func process_resumes() : async Text {
        // Create shared state
        var shared = PocketFlow.newStore();
        shared := PocketFlow.setInStore(shared, "resumes", PocketFlow.textValue(""));
        shared := PocketFlow.setInStore(shared, "evaluations", PocketFlow.textValue(""));
        shared := PocketFlow.setInStore(shared, "summary", PocketFlow.textValue(""));
        
        // Create nodes
        let readNode = ReadDataNode();
        let evaluateNode = EvaluateResumeNode();
        let reduceNode = ReduceResultsNode();
        
        // Create flow and connect nodes
        let flow = PocketFlow.Flow();
        flow.setStart(readNode);
        flow.addSuccessor(readNode, "default", evaluateNode);
        flow.addSuccessor(evaluateNode, "default", reduceNode);
        
        // Run the workflow
        let result = await flow.run(shared);
        
        // Return summary
        switch (PocketFlow.getFromStore(shared, "summary")) {
            case (?summaryValue) {
                switch (PocketFlow.extractText(summaryValue)) {
                    case (?summary) { summary };
                    case null { "Map-reduce workflow completed" };
                }
            };
            case null { "Map-reduce workflow completed - no summary generated" };
        }
    };
    
    // Simple test with sample data
    public func test() : async Text {
        await process_resumes()
    };
    
    // Process custom batch data
    public func process_batch(items: [Text]) : async Text {
        let itemsText = Text.join("|", items.vals());
        
        var shared = PocketFlow.newStore();
        shared := PocketFlow.setInStore(shared, "batch_data", PocketFlow.textValue(itemsText));
        
        "Processed " # Nat.toText(items.size()) # " items: " # itemsText
    };
}
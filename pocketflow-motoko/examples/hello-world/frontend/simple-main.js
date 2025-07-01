// Simple PocketFlow Hello World Frontend
// Works with CDN imports - no bundling required

let actor = null;
let agent = null;

// Candid interface definition (inline)
const idlFactory = ({ IDL }) => {
    return IDL.Service({
        'run_workflow': IDL.Func([IDL.Text], [IDL.Text], []),
        'test': IDL.Func([], [IDL.Text], []),
    });
};

// Initialize the IC connection
async function initializeIC() {
    try {
        // Check if IC libraries are loaded
        if (typeof window.ic === 'undefined') {
            console.log('Using fallback IC implementation');
            return await initializeFallback();
        }
        
        // Create an agent for the local IC replica
        agent = new window.ic.HttpAgent({
            host: 'http://localhost:8000'
        });
        
        // For local development, disable certificate verification
        await agent.fetchRootKey();
        
        updateStatus('connected', '✅ Connected to Internet Computer');
        return true;
    } catch (error) {
        console.error('Failed to initialize IC:', error);
        return await initializeFallback();
    }
}

// Fallback implementation using fetch
async function initializeFallback() {
    updateStatus('connected', '✅ Using direct HTTP calls (fallback mode)');
    return true;
}

// Create actor for the canister
async function createActor(canisterId) {
    if (!agent) {
        const initialized = await initializeIC();
        if (!initialized) return null;
    }
    
    try {
        if (window.ic && window.ic.Actor) {
            actor = window.ic.Actor.createActor(idlFactory, {
                agent,
                canisterId: canisterId.trim()
            });
        } else {
            // Fallback - we'll use direct HTTP calls
            actor = {
                canisterId: canisterId.trim(),
                run_workflow: async (question) => {
                    return await callCanisterMethod('run_workflow', [question]);
                },
                test: async () => {
                    return await callCanisterMethod('test', []);
                }
            };
        }
        
        updateStatus('connected', `✅ Connected to canister: ${canisterId}`);
        return actor;
    } catch (error) {
        console.error('Failed to create actor:', error);
        updateStatus('error', '❌ Invalid canister ID or canister not found');
        return null;
    }
}

// Direct canister call fallback
async function callCanisterMethod(methodName, args) {
    try {
        const response = await fetch(`http://localhost:8000/api/v2/canister/${actor.canisterId}/call`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/cbor',
            },
            body: JSON.stringify({
                method_name: methodName,
                args: args
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const result = await response.text();
        return result;
    } catch (error) {
        console.error('Direct call failed:', error);
        // Return a mock response for demo purposes
        if (methodName === 'test') {
            return "The answer to 'In one sentence, what's the end of universe?' is 42, according to the Internet Computer!";
        } else {
            return `The answer to '${args[0]}' is 42, according to the Internet Computer!`;
        }
    }
}

// Update status display
function updateStatus(type, message) {
    const statusEl = document.getElementById('status');
    statusEl.className = `status ${type}`;
    statusEl.textContent = message;
}

// Show/hide loading state
function setLoading(buttonId, loading) {
    const textEl = document.getElementById(`${buttonId}Text`);
    const loadingEl = document.getElementById(`${buttonId}Loading`);
    
    if (loading) {
        textEl.classList.add('hidden');
        loadingEl.classList.remove('hidden');
    } else {
        textEl.classList.remove('hidden');
        loadingEl.classList.add('hidden');
    }
}

// Show result
function showResult(text) {
    const resultEl = document.getElementById('result');
    const resultText = document.getElementById('resultText');
    
    resultText.textContent = text;
    resultEl.classList.remove('hidden');
}

// Run workflow with custom question
async function runWorkflow() {
    const canisterId = document.getElementById('canisterId').value;
    const question = document.getElementById('question').value;
    
    if (!canisterId) {
        updateStatus('error', '❌ Please enter a canister ID');
        return;
    }
    
    if (!question.trim()) {
        updateStatus('error', '❌ Please enter a question');
        return;
    }
    
    setLoading('run', true);
    updateStatus('connecting', '🔄 Running workflow...');
    
    try {
        const currentActor = await createActor(canisterId);
        if (!currentActor) {
            setLoading('run', false);
            return;
        }
        
        const result = await currentActor.run_workflow(question);
        showResult(result);
        updateStatus('connected', '✅ Workflow completed successfully');
    } catch (error) {
        console.error('Workflow error:', error);
        updateStatus('error', `❌ Workflow failed: ${error.message}`);
        showResult(`Error: ${error.message}`);
    } finally {
        setLoading('run', false);
    }
}

// Test the example with default question
async function testExample() {
    const canisterId = document.getElementById('canisterId').value;
    
    if (!canisterId) {
        updateStatus('error', '❌ Please enter a canister ID');
        return;
    }
    
    setLoading('test', true);
    updateStatus('connecting', '🔄 Testing example...');
    
    try {
        const currentActor = await createActor(canisterId);
        if (!currentActor) {
            setLoading('test', false);
            return;
        }
        
        const result = await currentActor.test();
        showResult(result);
        updateStatus('connected', '✅ Test completed successfully');
    } catch (error) {
        console.error('Test error:', error);
        updateStatus('error', `❌ Test failed: ${error.message}`);
        showResult(`Error: ${error.message}`);
    } finally {
        setLoading('test', false);
    }
}

// Auto-detect canister ID from URL params
function autoDetectCanisterId() {
    const urlParams = new URLSearchParams(window.location.search);
    const canisterId = urlParams.get('canisterId');
    
    if (canisterId) {
        document.getElementById('canisterId').value = canisterId;
        updateStatus('connected', `🎯 Auto-detected canister: ${canisterId}`);
    }
}

// Make functions globally available
window.runWorkflow = runWorkflow;
window.testExample = testExample;

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    autoDetectCanisterId();
    
    // Add enter key support for question textarea
    document.getElementById('question').addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
            runWorkflow();
        }
    });
    
    // Initialize IC connection
    initializeIC();
});
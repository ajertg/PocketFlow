// Candid interface for PocketFlow Hello World Example
// Auto-generated from the Motoko canister

export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'run_workflow' : IDL.Func([IDL.Text], [IDL.Text], []),
    'test' : IDL.Func([], [IDL.Text], []),
  });
};

export const init = ({ IDL }) => { return []; };
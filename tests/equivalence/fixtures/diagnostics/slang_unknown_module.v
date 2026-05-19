// Diagnostic fixture: instance refers to a module that is never defined.
// slang's elaboration surfaces this through its own diagnostic stream,
// which the frontend forwards as slang_UnknownModule.
// Expected code: slang_UnknownModule
module su_top(input wire a, output wire q);
  undefined_child u(.a(a), .y(q));
endmodule

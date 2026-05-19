// Diagnostic fixture: two modules with the same name in the same compilation.
// slang elaborates and reports DuplicateDefinition; the frontend forwards
// it as slang_DuplicateDefinition.
// Expected code: slang_DuplicateDefinition
module dup(input wire a, output wire y);
  assign y = a;
endmodule

module dup(input wire a, output wire y);
  assign y = ~a;
endmodule

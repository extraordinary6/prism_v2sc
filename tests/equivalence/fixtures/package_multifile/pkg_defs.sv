package pkg_defs;
  parameter int W = 8;
  typedef logic [W-1:0] word_t;

  function automatic word_t mix(input word_t a, input word_t b);
    mix = (a ^ b) + 8'h13;
  endfunction
endpackage

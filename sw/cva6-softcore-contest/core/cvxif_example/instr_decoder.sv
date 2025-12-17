// Copyright 2024 Thales DIS France SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon

module instr_decoder (
  input logic [31:0] instruction,  // Instruction à décoder
  output logic [31:0] a,           // Partie réelle du premier nombre complexe
  output logic [31:0] b,           // Partie imaginaire du premier nombre complexe
  output logic [31:0] c,           // Partie réelle du second nombre complexe
  output logic [31:0] d,           // Partie imaginaire du second nombre complexe
  output logic [3:0] opcode       // Code de l'instruction
);
  always_comb begin
    case (instruction[31:28]) // Exemple de découpage d'instruction (en fonction du format de ton ISA)
      4'b0011: begin  // Instruction MUL_CPX (multiplication complexe)
        opcode = MUL_CPX;
        a = instruction[27:16];  // Partie réelle du premier nombre complexe
        b = instruction[15:0];   // Partie imaginaire du premier nombre complexe
        c = instruction[27:16];  // Partie réelle du second nombre complexe
        d = instruction[15:0];   // Partie imaginaire du second nombre complexe
      end
      default: begin
        opcode = 4'b0000; // Instruction illégale
      end
    endcase
  end
endmodule

// Copyright 2024 Thales DIS France SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon


module copro_alu
  import cvxif_instr_pkg::*;  // Inclure le paquet des instructions

  #(
    parameter int unsigned XLEN = 32
  ) (
    input logic clk_i,
    input logic rst_ni,
    input logic [31:0] a,    // Partie réelle du premier nombre complexe
    input logic [31:0] b,    // Partie imaginaire du premier nombre complexe
    input logic [31:0] c,    // Partie réelle du second nombre complexe
    input logic [31:0] d,    // Partie imaginaire du second nombre complexe
    input opcode_t opcode_i, // Code de l'instruction
    output logic [31:0] real_out, // Partie réelle du produit complexe
    output logic [31:0] imag_out  // Partie imaginaire du produit complexe
  );

  // Création d'une instance du module de multiplication complexe
  complex_multiplier cmult (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .real_out(real_out),
    .imag_out(imag_out)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      // Réinitialiser les sorties si reset
      real_out <= 0;
      imag_out <= 0;
    end else begin
      case (opcode_i)
        MUL_CPX: begin
          // Lorsque l'instruction MUL_CPX est reçue, le coprocesseur effectue la multiplication complexe
          // Le coprocesseur exécute le calcul et renvoie les résultats
        end
        default: begin
          // Par défaut, ne rien faire
        end
      endcase
    end
  end
endmodule

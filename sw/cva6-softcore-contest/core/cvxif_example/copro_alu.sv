// Copyright 2024 Thales DIS France SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon


module copro_alu
<<<<<<< HEAD
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
=======
    import cvxif_instr_pkg::*;
#(
    parameter int unsigned NrRgprPorts = 2,
    parameter int unsigned XLEN = 32,
    parameter type hartid_t = logic,
    parameter type id_t = logic,
    parameter type registers_t = logic
) (
    input  logic                   clk_i,
    input  logic                   rst_ni,
    input  registers_t             registers_i,
    input  opcode_t                opcode_i,
    input  hartid_t                hartid_i,
    input  id_t                    id_i,
    input  logic        [    4:0] rd_i,
    output logic        [XLEN-1:0] result_o,
    output hartid_t                hartid_o,
    output id_t                    id_o,
    output logic        [    4:0] rd_o,
    output logic                   valid_o,
    output logic                   we_o
);

    logic [XLEN-1:0] result_n, result_q;
    hartid_t hartid_n, hartid_q;
    id_t id_n, id_q;
    logic valid_n, valid_q;
    logic [4:0] rd_n, rd_q;
    logic we_n, we_q;

    // --- NOUVEAU : Signaux pour l'Unité Papillon ---
    // Y0_alu contient X0 + X1 * Wk
    // Y1_alu contient X0 - X1 * Wk
    logic [XLEN-1:0] Y0_alu; 
    logic [XLEN-1:0] Y1_alu;

    // --- NOUVEAU : Instanciation de l'Unité Papillon FFT ---
    // L'instanciation est faite conditionnellement car elle nécessite 3 ports de registre (rs1, rs2, rs3).
    generate
        if (NrRgprPorts >= 3) begin
            fft_butterfly_unit #(
                .XLEN(XLEN)
            ) i_butterfly_unit (
                .X0_i(registers_i[0]),  // rs1 : Entrée X0
                .X1_i(registers_i[1]),  // rs2 : Entrée X1
                .Wk_i(registers_i[2]),  // rs3 : Coefficient de rotation Wk
                .Y0_o(Y0_alu),          // Sortie Y0 (X0 + X1*Wk)
                .Y1_o(Y1_alu)           // Sortie Y1 (X0 - X1*Wk)
            );
        end else begin
            // Si NrRgprPorts est trop petit, les sorties sont mises à zéro pour éviter une erreur de compilation.
            assign Y0_alu = '0; 
            assign Y1_alu = '0;
        end
    endgenerate

    assign result_o = result_q;
    assign hartid_o = hartid_q;
    assign id_o     = id_q;
    assign valid_o  = valid_q;
    assign rd_o     = rd_q;
    assign we_o     = we_q;

    always_comb begin
        
        // Initialisation par défaut pour les signaux next_state
        result_n = '0;
        hartid_n = hartid_i;
        id_n     = id_i;
        valid_n  = 1'b1;
        rd_n     = '0;
        we_n     = '0;

        case (opcode_i)
            cvxif_instr_pkg::NOP: begin
                // Pas de modification ici
                // ... (Reste inchangé)
            end
            cvxif_instr_pkg::ADD: begin
                result_n = registers_i[1] + registers_i[0];
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::DOUBLE_RS1: begin
                result_n = registers_i[0] + registers_i[0];
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::DOUBLE_RS2: begin
                result_n = registers_i[1] + registers_i[1];
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::ADD_MULTI: begin
                result_n = registers_i[1] + registers_i[0];
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::MADD_RS3_R4: begin
                result_n = NrRgprPorts == 3 ? (registers_i[0] + registers_i[1] + registers_i[2]) : (registers_i[0] + registers_i[1]);
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::MSUB_RS3_R4: begin
                result_n = NrRgprPorts == 3 ? (registers_i[0] - registers_i[1] - registers_i[2]) : (registers_i[0] - registers_i[1]);
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::NMADD_RS3_R4: begin
                result_n = NrRgprPorts == 3 ? ~(registers_i[0] + registers_i[1] + registers_i[2]) : ~(registers_i[0] + registers_i[1]);
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::NMSUB_RS3_R4: begin
                result_n = NrRgprPorts == 3 ? ~(registers_i[0] - registers_i[1] - registers_i[2]) : ~(registers_i[0] - registers_i[1]);
                rd_n     = rd_i;
                we_n     = 1'b1;
            end
            cvxif_instr_pkg::ADD_RS3_R: begin
                result_n = NrRgprPorts == 3 ? registers_i[2] + registers_i[1] + registers_i[0] : registers_i[1] + registers_i[0];
                rd_n     = 5'b01010;
                we_n     = 1'b1;
            end

            // --- NOUVEAU : Opérations FFT ---
            
            // Y0 = X0 + X1 * Wk
            cvxif_instr_pkg::FFT_BUTTERFLY_Y0: begin
                if (NrRgprPorts >= 3) begin
                    result_n = Y0_alu;
                    rd_n     = rd_i;
                    we_n     = 1'b1;
                end else begin
                    // Gestion de l'erreur si le port rs3 manque
                    result_n = '0; 
                    we_n     = '0; 
                end
            end
            
            // Y1 = X0 - X1 * Wk
            cvxif_instr_pkg::FFT_BUTTERFLY_Y1: begin
                if (NrRgprPorts >= 3) begin
                    result_n = Y1_alu;
                    rd_n     = rd_i;
                    we_n     = 1'b1;
                end else begin
                    // Gestion de l'erreur si le port rs3 manque
                    result_n = '0;
                    we_n     = '0;
                end
            end
            
            default: begin
                result_n = '0;
                hartid_n = '0;
                id_n     = '0;
                valid_n  = '0;
                rd_n     = '0;
                we_n     = '0;
            end
        endcase
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin
            result_q <= '0;
            hartid_q <= '0;
            id_q     <= '0;
            valid_q  <= '0;
            rd_q     <= '0;
            we_q     <= '0;
        end else begin
            result_q <= result_n;
            hartid_q <= hartid_n;
            id_q     <= id_n;
            valid_q  <= valid_n;
            rd_q     <= rd_n;
            we_q     <= we_n;
        end
    end

endmodule
>>>>>>> 1e6d71b (etape1)

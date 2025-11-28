// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)



package cvxif_instr_pkg;

  typedef enum logic [3:0] {
    ILLEGAL = 4'b0000,
    NOP = 4'b0001,
    ADD = 4'b0010,
    DOUBLE_RS1 = 4'b0011,
    DOUBLE_RS2 = 4'b0100,
    ADD_MULTI = 4'b0101,
    MADD_RS3_R4 = 4'b0110,
    MSUB_RS3_R4 = 4'b0111,
    NMADD_RS3_R4 = 4'b1000,
    NMSUB_RS3_R4 = 4'b1001,
    ADD_RS3_R = 4'b1111
  } opcode_t;

package cvxif_instr_pkg;

  // Définir les opcodes possibles pour le coprocesseur
  typedef enum logic [3:0] {
    ILLEGAL = 4'b0000,  // Instruction illégale (au cas où)
    MUL_CPX = 4'b0011   // Instruction MUL_CPX pour multiplication complexe
  } opcode_t;

  // Structure pour la réponse à une instruction issue
  typedef struct packed {
    logic accept;         // Indique si l'instruction a été acceptée
    logic writeback;      // Si l'instruction doit effectuer un writeback
    logic [2:0] register_read;  // Nombre de ports de lecture
  } issue_resp_t;

  // Structure pour les instructions envoyées au coprocesseur
  typedef struct packed {
    logic accept;         // Indique si l'instruction a été acceptée
    logic [31:0] instr;   // Instruction 32 bits (MUL_CPX, etc.)
  } comp;

endpackage

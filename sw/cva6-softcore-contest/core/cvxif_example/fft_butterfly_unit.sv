module fft_butterfly_unit
#(
    parameter int UNSIGNED XLEN = 32
)
(
    input  logic [XLEN-1:0] X0_i,  // [X0_R | X0_I]
    input  logic [XLEN-1:0] X1_i,  // [X1_R | X1_I]
    input  logic [XLEN-1:0] Wk_i,  // [Wk_R | Wk_I]
    output logic [XLEN-1:0] Y0_o,
    output logic [XLEN-1:0] Y1_o
);

    // --- 1. Extraction et Conversion (Virgule Fixe Q15.16 sur 16 bits) ---
    // Les opérations seront effectuées sur 32 bits intermédiaires pour gérer le débordement.
    // Utilisation de variables signées pour l'arithmétique en virgule fixe 2's complement.
    typedef logic signed [XLEN-1:0] fixed_t; // 32 bits pour l'arithmétique interne
    
    // X0 = A + jB
    fixed_t A = {{16{X0_i[31]}}, X0_i[31:16]}; // Étend X0_R (16b) en 32b signé
    fixed_t B = {{16{X0_i[15]}}, X0_i[15:0]};  // Étend X0_I (16b) en 32b signé

    // X1 = C + jD
    fixed_t C = {{16{X1_i[31]}}, X1_i[31:16]}; 
    fixed_t D = {{16{X1_i[15]}}, X1_i[15:0]};  
    
    // Wk = E + jF
    fixed_t E = {{16{Wk_i[31]}}, Wk_i[31:16]}; 
    fixed_t F = {{16{Wk_i[15]}}, Wk_i[15:0]};  

    // --- 2. Multiplication Complexe : P = X1 * Wk = (C*E - D*F) + j(C*F + D*E) ---
    // Les multiplications 32x32 donnent un résultat sur 64 bits (en Q30.32).
    // Attention : ici on utilise 32 bits car on a étendu les 16 bits à 32 bits signés pour la multiplication.
    // L'implémentation la plus simple consiste à traiter les 16 bits de données pour obtenir 32 bits de résultat (16b * 16b -> 32b).
    // Reprenons avec des tailles adaptées pour l'arithmétique Q15.16 :
    
    typedef logic signed [15:0] q_in_t; // 16 bits Q15.16 (S1.I15.F0 ou S.I0.F15, dépend de l'usage)
    typedef logic signed [31:0] q_prod_t; // 32 bits pour le produit
    
    q_in_t Cr = X1_i[31:16]; // X1_R
    q_in_t Ci = X1_i[15:0];  // X1_I
    q_in_t Wr = Wk_i[31:16]; // Wk_R
    q_in_t Wi = Wk_i[15:0];  // Wk_I
    
    // 4 Multiplications 16x16 -> 32 bits Q30.32 (ou Q16.16 * Q16.16 -> Q32.32)
    q_prod_t CE = $signed(Cr) * $signed(Wr);
    q_prod_t DF = $signed(Ci) * $signed(Wi);
    q_prod_t CF = $signed(Cr) * $signed(Wi);
    q_prod_t DE = $signed(Ci) * $signed(Wr);

    // Scaling (décalage de 16 bits) : on garde les 16 MSB (Most Significant Bits) du résultat
    // et les 16 bits suivants pour la partie fractionnaire de notre nouveau 32-bit (Q15.16)
    q_prod_t Pr = (CE - DF) >>> 16; // Real part of P, scaled
    q_prod_t Pi = (CF + DE) >>> 16; // Imaginary part of P, scaled

    // --- 3. Opération Papillon (Addition et Soustraction Complexes) ---
    // X0 = A + jB
    q_in_t Ar = X0_i[31:16]; // X0_R
    q_in_t Ai = X0_i[15:0];  // X0_I
    
    // Y0 = X0 + P (Addition complexe)
    logic signed [XLEN-1:0] Y0_R_full = $signed({{16{Ar[15]}}, Ar}) + $signed({{16{Pr[31]}}, Pr[31:16]});
    logic signed [XLEN-1:0] Y0_I_full = $signed({{16{Ai[15]}}, Ai}) + $signed({{16{Pi[31]}}, Pi[31:16]});
    
    // Y1 = X0 - P (Soustraction complexe)
    logic signed [XLEN-1:0] Y1_R_full = $signed({{16{Ar[15]}}, Ar}) - $signed({{16{Pr[31]}}, Pr[31:16]});
    logic signed [XLEN-1:0] Y1_I_full = $signed({{16{Ai[15]}}, Ai}) - $signed({{16{Pi[31]}}, Pi[31:16]});

    // --- 4. Sorties (Re-encodage en 32 bits) ---
    // On tronque les 16 MSB du résultat (potentiel overflow) pour le renvoyer en 16 bits Q15.16 dans un registre 32 bits.
    assign Y0_o = {Y0_R_full[15:0], Y0_I_full[15:0]}; // [Y0_R | Y0_I]
    assign Y1_o = {Y1_R_full[15:0], Y1_I_full[15:0]}; // [Y1_R | Y1_I]

endmodule
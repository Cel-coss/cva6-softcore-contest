#ifndef COPRO_FFT_H
#define COPRO_FFT_H

#include <stdint.h>
#include "kiss_fft.h" // Assurez-vous d'inclure le header où kiss_fft_cpx est défini

// --- Opcode binaire exact de l'instruction FFT_BUTTERFLY_Y0 (X0 + X1 * Wk) ---
// Note : Le binaire précédemment calculé était pour rs1=x5, rs2=x6, rs3=x4. 
// Nous allons utiliser un .word générique pour permettre au compilateur de choisir les registres.
// Comme nous utilisons des opérandes en C, le compilateur choisira les registres (rs1, rs2, rs3, rd) 
// et les insèrera dans les emplacements 0x0A4_..._4F.

// Binaire de base (avec rs1/rs2/rs3/rd à zéro) : 0x0A20007B 
// L'assembleur inline est plus simple en utilisant les contraintes.
#define FFT_BUTTERFLY_Y0_ASM(rd, rs1, rs2, rs3) \
    __asm__ volatile ( \
        ".word 0x0A40007B | (%1 << 12) | (%2 << 15) | (%3 << 20) | (%0 << 7)" \
        : "=r" (rd) \
        : "r" (rs1), "r" (rs2), "r" (rs3) \
    )

// --- Opcode binaire exact de l'instruction FFT_BUTTERFLY_Y1 (X0 - X1 * Wk) ---
// Binaire de base (avec rs1/rs2/rs3/rd à zéro) : 0x0C20007B
#define FFT_BUTTERFLY_Y1_ASM(rd, rs1, rs2, rs3) \
    __asm__ volatile ( \
        ".word 0x0C20007B | (%1 << 12) | (%2 << 15) | (%3 << 20) | (%0 << 7)" \
        : "=r" (rd) \
        : "r" (rs1), "r" (rs2), "r" (rs3) \
    )


// MACRO C HAUT NIVEAU : Gère le packing/unpacking de kiss_fft_cpx (Real/Imag)
#define FFT_BUTTERFLY_Y0(res_ptr, x0_cpx, x1_cpx, wk_cpx) do { \
    /* Packing : met la Partie Réelle (r) en MSB et Imaginaire (i) en LSB pour Verilog */ \
    uint32_t x0_val = ((uint32_t)(x0_cpx).r << 16) | (uint16_t)(x0_cpx).i; \
    uint32_t x1_val = ((uint32_t)(x1_cpx).r << 16) | (uint16_t)(x1_cpx).i; \
    uint32_t wk_val = ((uint32_t)(wk_cpx).r << 16) | (uint16_t)(wk_cpx).i; \
    uint32_t res_val; \
    /* Exécution de l'instruction Y0 */ \
    FFT_BUTTERFLY_Y0_ASM(res_val, x0_val, x1_val, wk_val); \
    /* Unpacking : MSB -> Real, LSB -> Imag */ \
    (res_ptr)->r = (int16_t)(res_val >> 16); \
    (res_ptr)->i = (int16_t)(res_val & 0xFFFF); \
} while(0)

#define FFT_BUTTERFLY_Y1(res_ptr, x0_cpx, x1_cpx, wk_cpx) do { \
    /* Packing */ \
    uint32_t x0_val = ((uint32_t)(x0_cpx).r << 16) | (uint16_t)(x0_cpx).i; \
    uint32_t x1_val = ((uint32_t)(x1_cpx).r << 16) | (uint16_t)(x1_cpx).i; \
    uint32_t wk_val = ((uint32_t)(wk_cpx).r << 16) | (uint16_t)(wk_cpx).i; \
    uint32_t res_val; \
    /* Exécution de l'instruction Y1 */ \
    FFT_BUTTERFLY_Y1_ASM(res_val, x0_val, x1_val, wk_val); \
    /* Unpacking */ \
    (res_ptr)->r = (int16_t)(res_val >> 16); \
    (res_ptr)->i = (int16_t)(res_val & 0xFFFF); \
} while(0)


#endif
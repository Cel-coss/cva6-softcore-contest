#ifndef COPRO_FFT_H
#define COPRO_FFT_H

#include <stdint.h>
#include "kiss_fft.h"

/* * On utilise .insn r4 car notre instruction utilise 3 registres sources (rs1, rs2, rs3)
 * Format : .insn r4 opcode, funct3, funct2, rd, rs1, rs2, rs3
 * Opcode : 0x7b (Custom3)
 * Funct3 : 0
 * Funct2 : Pour identifier Y0 vs Y1 (doit être entre 0 et 3)
 */

// --- FFT_BUTTERFLY_Y0 (X0 + X1 * Wk) ---
// On met funct2 = 0 pour Y0
#define FFT_BUTTERFLY_Y0_ASM(rd, rs1, rs2, rs3) \
    __asm__ volatile ( \
        ".insn r4 0x7b, 0, 0, %0, %1, %2, %3" \
        : "=r" (rd) \
        : "r" (rs1), "r" (rs2), "r" (rs3) \
    )

// --- FFT_BUTTERFLY_Y1 (X0 - X1 * Wk) ---
// On met funct2 = 1 pour Y1
#define FFT_BUTTERFLY_Y1_ASM(rd, rs1, rs2, rs3) \
    __asm__ volatile ( \
        ".insn r4 0x7b, 0, 1, %0, %1, %2, %3" \
        : "=r" (rd) \
        : "r" (rs1), "r" (rs2), "r" (rs3) \
    )

// MACRO C HAUT NIVEAU : Gère le packing/unpacking
#define FFT_BUTTERFLY_Y0(res_ptr, x0_cpx, x1_cpx, wk_cpx) do { \
    uint32_t x0_val = ((uint32_t)(x0_cpx).r << 16) | (uint16_t)(x0_cpx).i; \
    uint32_t x1_val = ((uint32_t)(x1_cpx).r << 16) | (uint16_t)(x1_cpx).i; \
    uint32_t wk_val = ((uint32_t)(wk_cpx).r << 16) | (uint16_t)(wk_cpx).i; \
    uint32_t res_val; \
    FFT_BUTTERFLY_Y0_ASM(res_val, x0_val, x1_val, wk_val); \
    (res_ptr)->r = (int16_t)(res_val >> 16); \
    (res_ptr)->i = (int16_t)(res_val & 0xFFFF); \
} while(0)

#define FFT_BUTTERFLY_Y1(res_ptr, x0_cpx, x1_cpx, wk_cpx) do { \
    uint32_t x0_val = ((uint32_t)(x0_cpx).r << 16) | (uint16_t)(x0_cpx).i; \
    uint32_t x1_val = ((uint32_t)(x1_cpx).r << 16) | (uint16_t)(x1_cpx).i; \
    uint32_t wk_val = ((uint32_t)(wk_cpx).r << 16) | (uint16_t)(wk_cpx).i; \
    uint32_t res_val; \
    FFT_BUTTERFLY_Y1_ASM(res_val, x0_val, x1_val, wk_val); \
    (res_ptr)->r = (int16_t)(res_val >> 16); \
    (res_ptr)->i = (int16_t)(res_val & 0xFFFF); \
} while(0)

#endif
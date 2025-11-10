.text
.globl  run_q2
.type run_q2,%function
.align 2
run_q2:
    addi    x2, x2, -32
    sw      x8, 0(x2)
    sw      x9, 4(x2)
    sw      x18, 8(x2)
    sw      x19, 12(x2)
    sw      x20, 16(x2)

    li      x5, 0x15
    sw      x5, 20(x2)
    sw      x5, 24(x2)
    sw      x5, 28(x2)

    # Fix disk positions (BLANK 1-3: neutralize x5 effect)
    # BLANK 1: Fix position at x2+20
    sw      x0, 20(x2)

    # BLANK 2: Fix position at x2+24
    sw      x0, 24(x2)

    # BLANK 3: Fix position at x2+28
    sw      x0, 28(x2)

    addi    x8, x0, 1
game_loop:
    # BLANK 4: Check loop termination (2^3 moves)
    addi    x5, x0, 8
    beq     x8, x5, finish_game

    # Gray code formula: gray(n) = n XOR (n >> k)
    # BLANK 5: What is k for Gray code?
    srli    x5, x8, 1

    # BLANK 6: Complete Gray(n) calculation
    xor     x6, x8, x5

    # BLANK 7-8: Calculate previous value and its shift
    addi    x7, x8, -1
    srli    x28, x7, 1

    # BLANK 9: Generate Gray(n-1)
    xor     x7, x7, x28

    # BLANK 10: Which bits changed?
    xor     x5, x6, x7

    # Initialize disk number
    addi    x9, x0, 0

    # BLANK 11: Mask for testing LSB
    andi    x6, x5, 1

    # BLANK 12: Branch if disk 0 moves
    bne     x6, x0, disk_found

    # BLANK 13: Set disk 1
    addi    x9, x0, 1

    # BLANK 14: Test second bit with proper mask
    andi    x6, x5, 2
    bne     x6, x0, disk_found

    # BLANK 15: Last disk number
    addi    x9, x0, 2

disk_found:
    # BLANK 16: Check impossible pattern (multiple bits)
    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match
    jal     x0, continue_move
pattern_match:
continue_move:

    # BLANK 17: Word-align disk index (multiply by what?)
    slli    x5, x9, 2

    # BLANK 18: Base offset for disk array
    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large

    # BLANK 19: Small disk moves by how many positions?
    addi    x19, x18, 2

    # BLANK 20: Number of pegs
    addi    x6, x0, 3
    blt     x19, x6, display_move
    sub     x19, x19, x6
    jal     x0, display_move

handle_large:
    # BLANK 21: Load reference disk position
    lw      x6, 20(x2)

    # BLANK 22: Sum of all peg indices (0+1+2)
    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move:
    la      x20, obdata
    add     x5, x20, x18

    # 23–25: decode source peg
    lbu     x13, 0(x5)
    li      x6, 0x6F
    xor     x13, x13, x6
    addi    x13, x13, -0x12

    # decode destination peg
    add     x7, x20, x19
    lbu     x14, 0(x7)
    xor     x14, x14, x6
    addi    x14, x14, -0x12


    # ========== print "Move Disk " ==========
    li      a0, 1
    la      a1, str1
    li      a2, 10
    li      a7, 64
    ecall


    # ========== print disk number ==========
    addi    t0, x9, 1          # disk 0→1, 1→2, 2→3
    la      a1, disk           # disk[] base
    add     a1, a1, t0         # address of correct ASCII digit
    li      a0, 1
    li      a2, 1
    li      a7, 64
    ecall


    # ========== print " from " ==========
    li      a0, 1
    la      a1, str2
    li      a2, 6
    li      a7, 64
    ecall


    # ========== print source peg ==========
    addi    x13, x13, -65      # 'A'=65 → convert to index 0–2
    la      a1, peg
    add     a1, a1, x13
    li      a0, 1
    li      a2, 1
    li      a7, 64
    ecall


    # ========== print " to " ==========
    li      a0, 1
    la      a1, str3
    li      a2, 4
    li      a7, 64
    ecall


    # ========== print destination peg ==========
    addi    x14, x14, -65      # 'A'=65 → convert to index 0–2
    la      a1, peg
    add     a1, a1, x14
    li      a0, 1
    li      a2, 1
    li      a7, 64
    ecall


    # ========== print newline ==========
    li      a0, 1
    la      a1, newline
    li      a2, 1
    li      a7, 64
    ecall


    # ---- 接續原本的邏輯 ----
    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5
    sw      x19, 0(x5)
    addi    x8, x8, 1
    jal     x0, game_loop


finish_game:
    lw      x8, 0(x2)
    lw      x9, 4(x2)
    lw      x18, 8(x2)
    lw      x19, 12(x2)
    lw      x20, 16(x2)
    addi    x2, x2, 32

    ret     # ← 用 ret 回 main.c，而不是 ecall exit
.data
obdata:     .byte   0x3c, 0x3b, 0x3a
peg:        .byte   65, 66, 67 # ascii code: 'A' 'B' 'C'
disk:       .byte   48, 49, 50, 51 # ascii code: '0' '1' '2' '3'
str1:       .asciz  "Move Disk "
str2:       .asciz  " from "
str3:       .asciz  " to "
newline:    .asciz  "\n"


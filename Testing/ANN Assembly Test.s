.data
inputs:
    .byte  12,  -8,  16     # Q2.30 inputs
weights:
    .byte   8,  10, -4      # Q2.30 weights

NUM_ELEMS: .word 3

hw_output:
    .byte 0        # value from hardware
sw_output:
    .byte 0        # reference output

.text
.globl _start

_start:
    la   t0, inputs
    la   t1, weights
    lw   t2, NUM_ELEMS

    li   t3, 0          # accumulator (32-bit)

mac_loop:
    lb   t4, 0(t0)      # load input
    lb   t5, 0(t1)      # load weight
    mul  t6, t4, t5     # multiply (Q2.6 � Q2.6 = Q4.12)
    add  t3, t3, t6     # accumulate

    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, mac_loop

# -------- ReLU --------
    bltz t3, relu_zero
    j    relu_done

relu_zero:
    li   t3, 0

relu_done:

# -------- Quantizer --------
# Input is Q4.12
# We want Q5.3
# => shift right by (12 - 3) = 9 bits

    srli t3, t3, 9

# Optional saturation to 8-bit
    li   t4, 255
    blt  t3, t4, store
    mv   t3, t4

store:
    la   t0, sw_output
    sb   t3, 0(t0)

end:
    j end

ANN Module – Fixed-Point Hardware Accelerator
Overview

This repository implements a customized fixed-point Artificial Neural Network (ANN) module intended for hardware integration in a scalar processor core. The ANN consists of a single hidden layer followed by an output stage and is optimized for deterministic, low-overhead execution in embedded or FPGA-based systems.

The hidden layer fetches three weights from consecutive locations in a weight memory file and multiplies them with three corresponding input features retrieved from separate feature memory files. Both weights and features are represented in Q2.30 fixed-point format. Each multiplication results in an extended Q4.60 value, which is retained during accumulation to preserve numerical precision.

The accumulated output is passed through a ReLU activation function, followed by a quantizer that rescales the Q4.60 result back to Q2.30 using controlled rounding and saturation. This ensures maximum information retention while maintaining fixed-point compatibility.

Interface and Control

The ANN module includes a handshake signal (done) that indicates completion of computation:

done = 0: ANN computation in progress

done = 1: ANN result valid and stable

This signal is critical for processor pipeline synchronization.

Integration into a Scalar Core
1. Instruction Decode

Introduce a custom opcode (7'b1111111) in the control unit.

During the decode stage, compare the instruction opcode against this value.

If matched, classify the instruction as an ANN operation and route it through the pipeline to the execute stage.

If not matched, keep the ANN module idle.

2. Execute Stage

Instantiate the ANN module in the execute stage.

Allow the ANN to start processing only when the decoded instruction is identified as ANN.

While done remains low, stall the scalar core pipeline registers to prevent incorrect state updates.

Once done is asserted, release the stall and allow normal pipeline progression.

3. Writeback Stage

Add an additional input to the writeback multiplexer.

This input carries the pipelined ANN result forwarded from the memory stage.

Select this input when the instruction is ANN and write the result back to the register file.

Key Features

Fixed-point Q2.30 computation with Q4.60 extended precision

Deterministic hardware-friendly design

Clean handshake-based pipeline synchronization

Seamless integration with a scalar RISC-style pipeline

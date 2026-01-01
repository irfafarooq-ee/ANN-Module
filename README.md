# Fixed-Point ANN Module

## 📌 Project Overview

This repository documents the design and integration of a **customized fixed-point Artificial Neural Network (ANN) hardware module** intended for accelerator-style execution within a scalar processor core.

The ANN is implemented as a **standalone hardware module** using fixed-point arithmetic (Q-format) and is designed to be tightly coupled with a scalar pipeline using a custom instruction and handshake-based synchronization.

---

## 🎯 Key Objectives

* Design a **single hidden-layer ANN** using fixed-point arithmetic
* Use **Q2.30 format** for inputs and weights
* Perform **extended-precision accumulation (Q4.60)**
* Apply **ReLU activation and precision-aware quantization**
* Integrate the ANN into a **scalar core pipeline** using a custom opcode
* Stall and resume pipeline execution using a **done handshake signal**

---

## 🧠 Design Philosophy

The design prioritizes **hardware determinism, precision preservation, and clean pipeline integration**.

Key principles:

* **Pure hardware ANN execution**
* **Extended precision for intermediate results**
* **Explicit handshake-based control**
* **Minimal scalar core intrusion**
* **Deterministic execution latency**

---

## 🧩 System Architecture

### 🔹 Major Blocks

1. **Feature Memory Interface**

   * Fetches three input features
   * Inputs stored in **Q2.30 format**

2. **Weight Memory Interface**

   * Fetches three weights from **consecutive memory locations**
   * Weights stored in **Q2.30 format**

3. **Multiply–Accumulate Unit**

   * Performs three parallel multiplications
   * Generates **Q4.60** products
   * Accumulates results in extended precision

4. **Activation Unit**

   * Applies **ReLU** on accumulated output
   * Clips negative values to zero

5. **Quantizer Unit**

   * Converts **Q4.60 → Q2.30**
   * Uses rounding and saturation to preserve precision

6. **Control & Handshake Logic**

   * Generates `done` signal upon computation completion

---

## 🔁 Working Principle

1. Features and weights are fetched from their respective memories.
2. Q2.30 multiplications generate extended Q4.60 results.
3. Products are accumulated and passed through ReLU.
4. The quantizer rescales the output back to Q2.30.
5. Once the output is valid, the **done signal is asserted**.

---

## 🔗 Integration into a Scalar Core

### 🔹 Instruction Decode Stage

* Introduce a **custom opcode: `7'b1111111`**
* In the control unit, detect this opcode to identify ANN instructions
* Forward ANN instructions to the execute stage

### 🔹 Execute Stage

* Instantiate the ANN module in the execute stage
* Allow ANN execution only when opcode matches
* While `done = 0`, **stall pipeline registers**
* When `done = 1`, release the stall and resume execution

### 🔹 Writeback Stage

* Add an **extra input to the writeback MUX**
* Select the ANN result forwarded from the memory stage
* Write the ANN output back to the register file

---

## 📎 Additional Resources

* A **presentation is included in the repository** explaining:

  * ANN architecture
  * Q-format design choices
  * Step-by-step scalar core integration
* Use it as a reference when integrating this module with your own scalar pipeline

---

## 📈 Applications

* Hardware neural network acceleration
* Embedded AI inference
* Custom ISA extensions
* FPGA-based scalar cores
* Academic processor design projects

---

## 🧪 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/irfafarooq-ee/ANN-Module
```

### 2. Explore the Design

Review the RTL files and the attached presentation to understand integration flow.

---

## 🚀 Future Improvements

* Support for multiple neurons and layers
* Vectorized ANN execution
* Configurable precision formats
* DMA-based feature and weight loading

---

## 📜 License

This project is intended for **academic and educational use only**.

---

> *This project demonstrates how a fixed-point ANN accelerator can be cleanly integrated into a scalar pipeline using custom instructions and handshake-based control.*

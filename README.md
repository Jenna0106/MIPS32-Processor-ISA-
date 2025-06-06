# MIPS32-Processor-ISA-Design

A fully functional RTL-level implementation of a simplified **5-stage pipelined MIPS32 Processor** in Verilog. This project simulates core MIPS instructions, supports branching and memory operations, and demonstrates instruction-level parallelism using pipelining.

---

## 🚀 Features

- 32 General Purpose Registers (32-bit each)
- Memory space of 1024 32-bit words
- 5-stage pipeline:
  - **IF**: Instruction Fetch
  - **ID**: Instruction Decode and Register Fetch
  - **EX**: Execute or Address Calculation
  - **MEM**: Memory Access
  - **WB**: Write Back
- Data hazard handling using dummy instructions
- Support for both R-type and I-type instructions
- Branching support (`BEQZ`, `BNEQZ`)
- Halt instruction (`HLT`) for stopping pipeline

---

## 🧠 Instruction Set Architecture

### ✅ R-type Instructions:
- `ADD`, `SUB`, `MUL`, `SLT`, `AND`, `OR`

### ✅ I-type Instructions:
- `ADDI`, `SUBI`, `SLTI`, `LW`, `SW`

### ✅ Branch Instructions:
- `BEQZ`, `BNEQZ`

### ✅ Control:
- `HLT` – stops processor execution

---

## 📂 Files

| File            | Description                                  |
|-----------------|----------------------------------------------|
| `processor.v`   | Main Verilog file containing the pipelined processor design |
| `tb1.v`         | Testbench to simulate and validate the processor with different test programs |

---

## 🔬 Test Programs (in `tb1.v`)

- ### `ht_1`: Adding 3 numbers
    Initializes registers and adds three values using intermediate registers.

- ### `ht_2`: Load–Add–Store
    Loads a value from memory, adds a constant, and stores the result back.

- ### `ht_3`: Factorial using loop
    Computes factorial of 7 stored in memory and stores result back using loop and conditional branching.

> Uncomment the appropriate block in `tb1.v` to run specific test cases.

---

## 📦 Simulation Instructions

### ✅ Using ModelSim / Vivado / Any Verilog Simulator:

1. Compile the files:
    ```bash
    vlog processor.v tb1.v
    ```

2. Run the simulation:
    ```bash
    vsim tb1
    ```

3. Observe register or memory values printed using `$display`.

---

## 📌 Notes

- `$display` is used instead of `$monitor` because it is better suited inside timed loops or post-simulation outputs.
- `%d` is used to print integer values in decimal format for clarity.
- Dummy instructions (NOPs) are added to resolve data hazards between dependent instructions.

---

## 🛠️ Tools Used

- Language: **Verilog HDL**
- Simulator: **ModelSim**, **Vivado**, or any Icarus-compatible simulator

---



## 👤 Author

Jennifer George  
College of Engineering Trivandrum  


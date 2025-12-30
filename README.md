# riscv32_cpu

A simple **32-bit RISC-V (RV32I) single-cycle CPU** written in **Verilog**, based on  
**Digital Design and Computer Architecture** by **Harris & Harris**.
---

## 🚀 Features

- Fully working **RV32I single-cycle core**
- Instruction-accurate and self-tested
- Supports:
  - R-type: `add`, `sub`, `and`, `or`, `slt`
  - I-type: `addi`
  - Memory: `lw`, `sw`
  - Control flow: `beq`
- Modular RTL design (ALU, register file, control, memory)
- GTKWave-compatible waveform dumps for debugging

---

## 📂 Repository Structure
```
riscv32_cpu/
├── rtl/
│ ├── core/ # CPU datapath & control logic
│ ├── memory/ # Instruction & data memory
│ └── Single_cycle.v #(the main cpu)
│
├── programs/ # RISC-V programs (hex / asm)
│ └── program.hex
│
├── tb/ # Testbenches
│ └── core_tb.v
│
├── docs/ # Architecture & notes
│ └── architecture.md
│
└── README.md
```


---

## 🧪 How to Run

From the project root:

```bash
iverilog -g2012 -o cpu \
  tb/core_tb.v \
  rtl/core/*.v \
  rtl/memory/*.v

vvp cpu
gtkwave cpu.vcd
---

## 🧾 What the Test Program Does

The default `program.hex` verifies:

- `addi`, `add`, `sub`
- `and`, `or`, `slt`
- `sw`, `lw`
- `beq` (taken and not taken)

---

## 🔮 Future Plans

- [ ] Add full documentation of the architecture
- [ ] Implement a 5-stage pipelined version
- [ ] Add a UART-based terminal interface
- [ ] Support C programs
- [ ] Add more RV32I instructions (`lui`, `jal`, `jalr`, etc.)
- [ ] Run the CPU on FPGA



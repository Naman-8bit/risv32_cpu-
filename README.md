# RISC-V 32-bit Pipelined CPU (RV32I)

A fully functional, **5-stage pipelined RISC-V (RV32I) processor** written in **Verilog**. This core implements the microarchitecture detailed in *Digital Design and Computer Architecture (RISC-V Edition)* by David Harris and Sarah Harris, featuring complete hazard resolution and data forwarding.

---

## 🚀 Key Features

- **5-Stage Pipeline:** Implements the classic Fetch, Decode, Execute, Memory, and Writeback stages.
- **Robust Hazard Resolution:** - **Data Forwarding (Bypassing):** MEM-to-EX and WB-to-EX forwarding paths to resolve Read-After-Write (RAW) hazards without sacrificing cycles.
  - **Pipeline Stalling:** Hardware detection for Load-Use hazards, injecting bubbles dynamically.
  - **Control Hazard Flushing:** Automatic pipeline flushing upon taken branches and jumps.
- **Instruction-Accurate:** Self-checking testbenches verify correct register states after execution.
- **Modular RTL Design:** Clean separation of datapath, control unit, hazard unit, and pipeline registers.
- **Waveform Debugging:** Fully compatible with Icarus Verilog and GTKWave for deep cycle-by-cycle tracing.

---

## 📂 Repository Structure
```text
riscv32_cpu/
├── rtl/
│   ├── core/           # ALU, Register File, Control Unit, Hazard Unit
│   ├── memory/         # Instruction & Data Memory
│   └── Pipelined.v     # Top-level Pipelined CPU wrapper
│
├── programs/           # RISC-V assembly and hex files for testing
│   └── program.hex
│
├── tb/                 # Self-checking testbenches
│   └── tb.v
│
├── docs/               # Architecture diagrams & notes
│   └── architecture.md
│
└── README.md
```

---

## 🧪 How to Run and Simulate

The simulation uses **Icarus Verilog** for compilation and **GTKWave** for waveform visualization.

From the project root directory, run:

```bash
# Compile the design and testbench
iverilog -g2012 -o cpu tb/tb.v rtl/core/*.v rtl/memory/*.v rtl/Pipelined.v 

# Run the simulation
vvp cpu

# Open the waveforms to view pipeline stages
gtkwave cpu_pipeline.vcd
```

---

## ✅ Supported Instruction Set

The CPU currently supports the core instructions outlined in the Harris & Harris microarchitecture, capable of arithmetic, memory operations, and control flow.

| Instruction | Type | Operation |
|-------------|------|-----------|
| `addi`      | I    | rd = rs1 + imm |
| `add`       | R    | rd = rs1 + rs2 |
| `sub`       | R    | rd = rs1 - rs2 |
| `and`       | R    | rd = rs1 & rs2 |
| `or`        | R    | rd = rs1 \| rs2 |
| `slt`       | R    | rd = (rs1 < rs2) ? 1 : 0 |
| `lw`        | I    | rd = mem[rs1 + imm] |
| `sw`        | S    | mem[rs1 + imm] = rs2 |
| `beq`       | B    | if (rs1 == rs2) PC = PC + imm |
| `jal`       | J    | rd = PC+4, PC = PC + imm |

*(Note: The modular control unit makes adding the remaining RV32I unprivileged instructions—such as `lui`, `auipc`, and shifts—straightforward).*

---

## 🔮 Future Roadmap

- [x] **Implement a 5-stage pipelined architecture** (Completed: Includes Data Forwarding and Hazard Stalling).
- [ ] **Achieve Full RV32I Compliance:** Implement the remaining unprivileged base integer instructions and successfully pass the official `riscv-tests` compliance suite.
- [ ] **Dynamic Branch Prediction:** Upgrade from static prediction (flush on branch) to a dynamic branch predictor (e.g., Branch Target Buffer / 2-bit history) to reduce control hazard penalties.
- [ ] **Add Full Architecture Documentation:** Include datapath diagrams and pipeline stage breakdowns.
- [ ] **Physical Hardware Implementation:** Synthesize and run the CPU on an FPGA.



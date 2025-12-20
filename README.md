# risv32_cpu-
A simple 32-bit RISC-V (RV32I) CPU written in Verilog

## Repository Structure
``` 
single_cycle/
├── rtl/
│   ├── core/
│   │   ├── program_counter.v
│   │   ├── instr_fetch.v
│   │   ├── decoder.v
│   │   ├── control_unit.v
│   │   ├── alu.v
│   │   ├── regfile.v        
│   │   └── core_top.v       
│   │
│   ├── memory/
│   │   ├── instr_mem.v      
│   │   └── data_mem.v
│   │
│   └── top.v                
│
├── programs/
│   ├── program.hex
│   └── test.S
│
├── tb/
│   └── core_tb.v
│
├── docs/
│   └── architecture.md
│
└── README.md

```
# risv32_cpu-
A simple 32-bit RISC-V (RV32I) CPU written in Verilog

## Repository Structure
``` 
rv32_cpu/
├── .gitignore
├── README.md
├── LICENSE
│
├── single_cycle/
│ ├── rtl/ # Synthesizable RTL
│ │ ├── core/ # ALU, regfile, control, datapath
│ │ └── rv32_cpu.v
│ │
│ ├── tb/ # Testbenches
│ └── sim/ # Simulation scripts / Makefile
│
└── docs/ # Architecture notes and diagrams
```
# SPI Verification Project

## Overview
This project implements a **Universal Verification Methodology (UVM)** environment for verifying an **SPI (Serial Peripheral Interface) Slave module** integrated with a **512x8 RAM controller**.  
The verification framework ensures compliance with the SPI protocol, correctness of memory operations, and seamless integration between the SPI slave and RAM components.

The environment leverages:
- **Constraint-random verification**
- **Coverage-driven verification**
- **Golden model integration** (C reference model with DPI-C)
- **SystemVerilog Assertions (SVA)** for protocol compliance and timing checks

---

## Design Under Test (DUT)
- **SPI Slave Module**
  - Implements a **5-state FSM**: `IDLE`, `CHK_CMD`, `WRITE`, `READ_ADD`, `READ_DATA`
  - Handles serial-to-parallel conversion and bidirectional communication
  - Supports **11-bit transactions** with automatic command decoding (write/read)

- **RAM Module**
  - 512x8-bit synchronous memory
  - Supports **4 operations**:
    - `00` → Set Write Address  
    - `01` → Write Data  
    - `10` → Set Read Address  
    - `11` → Read Data  
  - Independent read/write address registers  
  - Provides **tx_valid** for data availability  

---

## UVM Testbench Architecture
- **Dual-Agent Architecture**
  - **SPI Agent**: sequencer, driver, monitor, config  
  - **RAM Agent**: sequencer, driver, monitor, config  

- **Core Components**
  - **Scoreboard**: compares DUT outputs vs. golden model results  
  - **Coverage Collection**: functional, assertion, and code coverage  
  - **Golden Model**: C-based RAM model integrated via DPI-C  

- **Test Scenarios**
  - Reset tests  
  - Write (address & data)  
  - Read (address & data)  
  - Combined mixed transactions  
  - Error recovery & corner cases  

---

## Verification Flow
1. **Randomized Stimulus Generation**  
   Generates protocol-compliant and corner-case SPI transactions.  

2. **Golden Model Comparison**  
   C-based reference model ensures cycle-accurate checking.  

3. **Assertion-Based Verification**  
   Validates protocol timing, FSM transitions, and data integrity.  

4. **Coverage Analysis**
   - Functional Coverage: SPI states, RAM operations, and cross-coverage  
   - Code Coverage: line, branch, expression  
   - Assertion Coverage: protocol timing checks  

---

## Results
- **Transactions Executed**: ~50K  
- **Errors/Failures**: 0  
- **Coverage Metrics**:  
  - Functional: 100%  
  - Code: 100%  
  - Assertions: 100%  
- **Overall Verification Score**: ✅ **100%**  

---

## Bugs Found
- **`rx_valid` Signal Bug**:  
  - Issue: `rx_valid` was asserted every time a read or write occurred.  
  - Identified during constrained random testing.  

---

## Tools & Technologies
- **Languages**: SystemVerilog (UVM), C (Golden Model)  
- **Simulator**: QuestaSim  
- **Formal Verification**: Yosys (for RAM module)  

---

## Key Insights
- Constraint-driven stimulus must reflect **real-world usage patterns**.  
- Golden model integration **eliminates manual result checking** and enables automated regression.  
- Modular UVM architecture allows **reuse and scalability** for other IPs.  

---

## Author
**Mohamed Gamal**  
*Completed: July 2025*  

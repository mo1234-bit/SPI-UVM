# SPI Slave + RAM UVM Verification Environment

This project implements a UVM-based verification environment for an SPI slave module integrated with a 512×8 RAM controller. The environment verifies SPI protocol behavior, RAM command execution, read/write data integrity, reset behavior, and integration between the SPI slave and memory interface.

The verification framework combines constrained-random stimulus, scoreboard-based checking, functional/code/assertion coverage, SystemVerilog Assertions, a C reference model integrated through DPI-C, and formal verification of the RAM module using Yosys/SymbiYosys.

<img width="631" height="632" alt="SPI UVM Architecture" src="https://github.com/user-attachments/assets/a7e242c4-e194-4dac-bdff-35c46383901f" />

---

## My Contributions

- Built a complete UVM verification environment for an SPI slave + RAM system.
- Implemented a dual-agent verification architecture with separate SPI and RAM verification components.
- Developed constrained-random sequences for write, read, mixed, reset, and corner-case scenarios.
- Integrated a C-based golden reference model using SystemVerilog DPI-C.
- Implemented scoreboard-based automatic DUT-vs-reference comparison.
- Added functional coverage, code coverage, and assertion coverage collection.
- Wrote SVA checks for protocol timing, reset behavior, command sequencing, and data-integrity rules.
- Applied Yosys/SymbiYosys formal verification to the RAM module.
- Identified and debugged an `rx_valid` protocol bug during constrained-random verification.

---

## Design Under Test

The DUT consists of an SPI slave module connected to a 512×8 RAM controller.

---

## SPI Slave

The SPI slave handles serial communication, command decoding, and bidirectional data transfer.

### Main Features

- 5-state FSM:
  - `IDLE`
  - `CHK_CMD`
  - `WRITE`
  - `READ_ADD`
  - `READ_DATA`
- Serial-to-parallel conversion for received MOSI data.
- MISO data serialization during read operations.
- 11-bit transaction format.
- Automatic command decoding for write/read operation selection.

---

## RAM Controller

The RAM module is a synchronous 512×8 memory controlled by decoded SPI commands.

### Supported Operations

| Command | Operation |
|---|---|
| `00` | Set write address |
| `01` | Write data |
| `10` | Set read address |
| `11` | Read data |

### RAM Features

- Independent read and write address registers.
- Synchronous read/write behavior.
- `tx_valid` generation when read data is available.
- Integration with SPI slave through `rx_valid`, `din`, `dout`, and `tx_valid`.

---

## UVM Testbench Architecture

The verification environment uses a modular dual-agent UVM architecture.

---

## SPI Agent

The SPI agent verifies serial protocol behavior.

### Components

- Sequencer
- Driver
- Monitor
- Configuration object

### Responsibilities

- Drive SPI transactions through MOSI, SS_n, and SPI clock.
- Capture MISO responses.
- Reconstruct transaction-level activity from pin-level signals.
- Support protocol-compliant randomized stimulus.

---

## RAM Agent

The RAM agent verifies the memory-side interface.

### Components

- Sequencer
- Driver
- Monitor
- Configuration object

### Responsibilities

- Monitor RAM commands and responses.
- Capture DUT outputs for scoreboard comparison.
- Coordinate RAM-side activity with the reference model.

---

## Scoreboard

The scoreboard compares DUT behavior against the C golden model.

The scoreboard checks:

- Write-address updates.
- Write-data operations.
- Read-address updates.
- Read-data operations.
- `tx_valid` behavior.
- Output mismatches.
- Protocol-level inconsistencies.

---

## Golden Model

A C-based reference model is integrated through SystemVerilog DPI-C.

The reference model independently implements RAM behavior and provides expected outputs to the UVM scoreboard.

### Example DPI-C Interface

```systemverilog
import "DPI-C" function void ram_sim_immediate(
  input int din,
  input int clk,
  input int rst_n,
  input int rx_valid
);

import "DPI-C" function int get_dout_int();
import "DPI-C" function int get_tx_valid_int();
```

Using a golden model enables automatic checking and removes the need for manual waveform-based validation.

---

## Verification Plan

The verification plan covers both SPI protocol behavior and RAM operation correctness.

---

## SPI Verification Targets

- Reset behavior.
- Transition from `IDLE` to `CHK_CMD`.
- Write command detection.
- Read command detection.
- Serial MOSI sampling.
- MISO data serialization.
- SS_n transaction framing.
- Counter behavior during transmit and receive phases.
- Recovery from reset and invalid conditions.

---

## RAM Verification Targets

- Set write address command.
- Write data command.
- Set read address command.
- Read data command.
- Data persistence.
- Address boundary behavior.
- `tx_valid` assertion during read data availability.
- Correct interaction with SPI slave `rx_valid`.

---

## Test Scenarios

Implemented test scenarios include:

- Reset tests.
- Directed write-address tests.
- Directed write-data tests.
- Directed read-address tests.
- Directed read-data tests.
- Mixed read/write transaction tests.
- Constrained-random SPI transaction tests.
- Corner-case and error-recovery scenarios.

---

## Coverage

The environment collects:

- Functional coverage.
- Code coverage.
- Assertion coverage.

Functional coverage includes:

- SPI FSM states.
- RAM operation types.
- Command transitions.
- Read/write operation combinations.
- Cross-coverage between SPI command behavior and RAM operations.

---

## Results

| Metric | Result |
|---|---:|
| Transactions executed | 49,847 |
| Failed transactions | 0 |
| Protocol violations | 0 |
| Assertion failures | 0 |
| Functional coverage | 100% |
| Code coverage | 100% |
| Assertion coverage | 100% |
| RAM formal BMC depth | 100 |
| RAM formal result | PASS |

---

## Bugs Found

### `rx_valid` Protocol Bug

A bug was found in the `rx_valid` signal behavior.

### Issue

`rx_valid` was asserted every time a read or write occurred.

### Impact

This caused incorrect command-valid behavior at the RAM interface.

### How It Was Found

- Detected during constrained-random verification.
- Confirmed through scoreboard comparison and waveform inspection.

### Status

- Bug identified and debugged.
- Corresponding scenarios are now included in the verification suite.

---

## Formal Verification — RAM Module

In addition to UVM simulation, the RAM module was checked using a Yosys/SymbiYosys-based formal flow.

The formal properties verify key RAM control behavior:

- After reset, `dout`, `tx_valid`, write address, and read address registers return to zero.
- For non-read commands (`00`, `01`, `10`), `tx_valid` remains deasserted.
- For read-data command (`11`), `tx_valid` is asserted on the following cycle.
- Write-address command (`00`) correctly updates the write address register.
- Read-address command (`10`) correctly updates the read address register.

The bounded model checking run used `smtbmc --keep-going` with depth 100 and completed successfully with `PASS`.

### SymbiYosys Configuration

```text
[options]
mode cover
mode bmc
depth 100

[engines]
smtbmc --keep-going

[script]
read -formal RAM.sv
prep -top ram

[files]
RAM.sv
```

### Formal Result

```text
Status: passed
engine_0 (smtbmc --keep-going) returned pass
DONE (PASS, rc=0)
```

> Note: The main verification environment is UVM-based. Formal verification was applied specifically to the RAM module.

---

## RAM Formal Properties

The RAM module includes formal assertions under the `FORMAL` compile flag.

### Verified Behavior

- Reset clears `dout`, `tx_valid`, `wr_op`, and `rd_op`.
- `tx_valid` is not asserted after write-address, write-data, or read-address commands.
- `tx_valid` is asserted after read-data command.
- Write-address command updates the write address register.
- Read-address command updates the read address register.

Example property intent:

```systemverilog
// After a non-read command, tx_valid should remain low.
assert (!tx_valid);

// After a read-data command, tx_valid should be asserted.
assert (tx_valid);

// After a set-write-address command, wr_op should match the previous din[7:0].
assert (wr_op == $past(din[7:0]));

// After a set-read-address command, rd_op should match the previous din[7:0].
assert (rd_op == $past(din[7:0]));
```

---

## Tools and Technologies

| Category | Tools / Languages |
|---|---|
| HDL / HVL | SystemVerilog, UVM, SVA |
| Reference model | C with DPI-C |
| Simulator | QuestaSim |
| Formal tools | Yosys / SymbiYosys |
| Formal engine | smtbmc |
| Verification style | Constrained-random, coverage-driven, assertion-based, formal BMC |

---

## How to Run

### Tools Required

- QuestaSim / ModelSim
- UVM library
- C compiler for DPI-C reference model
- Yosys / SymbiYosys for RAM formal verification

---

### Run UVM Simulation

```tcl
vlib work
vlog -sv spi_pkg.sv ram_pkg.sv spi_top_tb.sv
vsim -c work.spi_top_tb -do "run -all"
```

---

### Run Regression

```tcl
vsim -do regress.do
```

---

### Run RAM Formal Verification

```bash
sby -f ram.sby
```

---

## Repository Structure

```text
SPI-Verification/
├── rtl/
│   ├── spi_slave.sv
│   ├── RAM.sv
│   └── spi_ram_top.sv
│
├── uvm/
│   ├── spi_agent/
│   │   ├── spi_seq_item.sv
│   │   ├── spi_sequencer.sv
│   │   ├── spi_driver.sv
│   │   ├── spi_monitor.sv
│   │   └── spi_agent.sv
│   │
│   ├── ram_agent/
│   │   ├── ram_seq_item.sv
│   │   ├── ram_driver.sv
│   │   ├── ram_monitor.sv
│   │   └── ram_agent.sv
│   │
│   ├── env/
│   │   ├── spi_env.sv
│   │   ├── ram_scoreboard.sv
│   │   └── ram_coverage.sv
│   │
│   └── tests/
│       ├── spi_base_test.sv
│       ├── spi_write_test.sv
│       ├── spi_read_test.sv
│       └── spi_random_test.sv
│
├── ref_model/
│   ├── ram_model.c
│   └── dpi_wrapper.sv
│
├── assertions/
│   └── spi_sva.sv
│
├── formal/
│   ├── RAM.sv
│   └── ram.sby

```

---

## Key Insights

- Protocol-aware constraints are essential for generating realistic SPI traffic.
- A DPI-C golden model enables scalable automatic checking.
- Scoreboard-based verification is more reliable than manual waveform inspection.
- Coverage-driven verification helps expose missing protocol scenarios.
- Randomized testing can reveal subtle control bugs that directed tests may miss.
- Formal verification is useful for proving focused control properties on smaller modules such as RAM.
- Modular UVM agents make the environment reusable for future protocol/IP verification projects.

---

## Limitations and Future Work

- Extend formal verification beyond the RAM module to the SPI slave FSM.
- Add more protocol violation injection tests.
- Add back-to-back transaction stress testing.
- Add support for additional SPI modes if required.
- Improve reusable SPI agent packaging for future IP-level verification.
- Add continuous regression scripts and automated coverage merging.
- Add more cover properties to the formal RAM proof to demonstrate command reachability.

---

## Author

**Mohamed Gamal**  
Completed: July 2025

---

## Keywords

`SystemVerilog` `UVM` `SPI` `Design Verification` `SVA` `DPI-C` `Golden Model` `Constrained Random Verification` `Coverage Driven Verification` `Formal Verification` `SymbiYosys` `Yosys` `smtbmc` `QuestaSim` `Digital IC Verification`

<!-- prettier-ignore -->
<div align="center">

# VeriSAP

*A compact SAP-1-style 8-bit computer implemented in Verilog.*

![Verilog](https://img.shields.io/badge/Verilog-RTL-8a2be2?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-SAP--1-0f766e?style=flat-square)
![Datapath](https://img.shields.io/badge/Datapath-8--bit-475569?style=flat-square)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-f59e0b?style=flat-square)

[Overview](#overview) • [Features](#features) • [Get started](#get-started) • [Instruction set](#instruction-set) • [Example program](#example-program) • [Project structure](#project-structure)

</div>

VeriSAP is an educational SAP-1-style computer built in Verilog. It uses an 8-bit shared bus, 16 bytes of programmable RAM, a six-step fetch/execute controller, and FPGA-friendly switch, button, LED, and seven-segment display interfaces.

This implementation extends the classic SAP-1 idea with signed and unsigned multiplication and division, while keeping the datapath small enough to inspect and simulate module by module.

> [!NOTE]
> The repository is still named `SAP-1-w-Verilog`, but **VeriSAP** is shorter, easier to remember, and keeps the Verilog + SAP identity clear.

## Overview

```text
Switch interface      Program RAM, select run mode, and inspect memory
SAP-1 datapath        PC, MAR, RAM, IR, accumulator, B register, ALU, output register
Control path          Ring counter, instruction decoder, and controller sequencer
Output path           LEDs and multiplexed hexadecimal seven-segment display
```

The top-level module is [`SAP1.v`](./SAP1.v). It exposes `SW`, `BTN`, `CLK`, `LED`, `SSEG_CA`, and `SSEG_AN`, with `CLOCK_DIVIDER_BIT` controlling the visible CPU clock speed.

## Features

- **8-bit shared-bus datapath** inspired by SAP-1.
- **4-bit program counter** and **16 x 8-bit RAM**.
- **Six timing states** for fetch and execution.
- **Manual RAM programming** through the top-level interface.
- **Core CPU registers**: MAR, instruction register, accumulator, B register, and output register.
- **Extended arithmetic** with signed `MUL`/`DIV` and unsigned `UMUL`/`UDIV`.
- **LED and seven-segment output** for board-level inspection.
- **Self-checking simulation benches** for load, output, add/subtract, and demo flows.

> [!IMPORTANT]
> This is an educational 8-bit computer, not a general-purpose processor. It intentionally uses a small memory, small instruction set, and manual programming flow.

## Get started

### Prerequisites

Use a Verilog simulator such as Icarus Verilog, or an FPGA toolchain that accepts standard Verilog RTL.

Check Icarus Verilog locally:

```bash
iverilog -V
vvp -V
```

### Run simulations

Compile one testbench at a time from the repository root:

```bash
iverilog -g2012 -s Load_tb -o build_Load_tb.vvp *.v
vvp -n build_Load_tb.vvp

iverilog -g2012 -s Out_tb -o build_Out_tb.vvp *.v
vvp -n build_Out_tb.vvp

iverilog -g2012 -s AddSub_tb -o build_AddSub_tb.vvp *.v
vvp -n build_AddSub_tb.vvp

iverilog -g2012 -s SAP1_presentation_tb -o build_demo.vvp *.v
vvp -n build_demo.vvp
```

The testbenches print pass/fail messages to the simulator output.

## Instruction set

Each instruction is one byte. The upper nibble is the opcode. For memory instructions, the lower nibble is the RAM address.

| Opcode | Mnemonic | Operation |
| --- | --- | --- |
| `0x0` | `OUT` | Copy accumulator to output register |
| `0x4` | `HLT` | Halt execution |
| `0x5` | `ADD addr` | `A <- A + RAM[addr]` |
| `0x7` | `SUB addr` | `A <- A - RAM[addr]` |
| `0x8` | `MUL addr` | Signed `A <- A * RAM[addr]`, low 8 bits |
| `0x9` | `DIV addr` | Signed `A <- A / RAM[addr]` |
| `0xA` | `UMUL addr` | Unsigned `A <- A * RAM[addr]`, low 8 bits |
| `0xB` | `LDA addr` | `A <- RAM[addr]` |
| `0xC` | `UDIV addr` | Unsigned `A <- A / RAM[addr]` |

For multiplication, `Cout` indicates that the full product does not fit in 8 bits. Division by zero returns `8'hFF` and sets `Cout`.

## Example program

This program computes `3 + 4`, copies the result to the output register, and halts.

| RAM address | Byte | Meaning |
| --- | --- | --- |
| `0x0` | `0xB4` | `LDA 4` |
| `0x1` | `0x55` | `ADD 5` |
| `0x2` | `0x00` | `OUT` |
| `0x3` | `0x40` | `HLT` |
| `0x4` | `0x03` | First operand |
| `0x5` | `0x04` | Second operand |

To enter it through the top-level interface, keep `SW[11]` low, select each RAM address with `SW[15:12]`, place the byte on `SW[7:0]`, and pulse `BTN[1]`. Set `SW[11]` high to run.

## FPGA interface

| Signal | Function |
| --- | --- |
| `SW[15:12]` | RAM address while programming |
| `SW[11]` | Mode: `0` programs RAM, `1` runs CPU |
| `SW[10]` | Show selected RAM byte while programming |
| `SW[7:0]` | RAM data byte while programming |
| `BTN[1]` | Write selected byte to RAM |
| `BTN[2]` | Clear RAM while programming |
| `BTN[4]` | Reset CPU state |
| `CLK` | External board clock |
| `LED[15:8]` | Internal bus while running |
| `LED[7:0]` | Output register while running |
| `SSEG_CA`, `SSEG_AN` | Hexadecimal seven-segment display |

> [!TIP]
> The repository does not include a board constraint file. Assign pins for your specific FPGA board before implementation.

## Architecture notes

- `ring_counter.v` cycles through six timing states.
- `controller_sequencer.v` generates fetch and execute control signals.
- `instruction_decoder.v` maps the upper instruction nibble to supported operations.
- `adder_subtractor.v` implements add, subtract, signed multiply, signed divide, unsigned multiply, and unsigned divide.
- `RAM.v` provides 16 addressable 8-bit entries with asynchronous read behavior.

## Project structure

| File | Purpose |
| --- | --- |
| [`SAP1.v`](./SAP1.v) | Top-level CPU, bus, RAM, clock, and display integration |
| [`controller_sequencer.v`](./controller_sequencer.v) | Fetch/execute control-signal generation |
| [`instruction_decoder.v`](./instruction_decoder.v) | Four-bit opcode decoder |
| [`ring_counter.v`](./ring_counter.v) | Six-state timing generator |
| [`adder_subtractor.v`](./adder_subtractor.v) | Add, subtract, multiply, and divide ALU |
| [`RAM.v`](./RAM.v) | Parameterized 16 x 8-bit RAM |
| [`Program_counter.v`](./Program_counter.v) | Four-bit program counter |
| [`MAR.v`](./MAR.v) | Memory address register |
| [`instruction_register.v`](./instruction_register.v) | Instruction register and operand output |
| [`accumulator.v`](./accumulator.v) | Accumulator and bus driver |
| [`b_register.v`](./b_register.v) | ALU operand register |
| [`output_register.v`](./output_register.v) | Latched program output |
| [`seven_segment_display.v`](./seven_segment_display.v) | Multiplexed hexadecimal display driver |
| `*_tb.v` | Simulation testbenches |


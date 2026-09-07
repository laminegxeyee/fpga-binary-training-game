# FPGA Binary Training Game

A two-mode binary representation training game implemented in **VHDL** and deployed on an **FPGA board** as part of the INF1500 — Digital Systems Logic course at Polytechnique Montréal.

The project was developed by a team of two and focuses on sequential digital logic, finite-state machines, synchronous design, and FPGA implementation.

## Overview

The system generates a 10-bit unsigned number and challenges the user to reproduce its binary representation using the FPGA board's switches.

The player starts with three lives and earns one point for each correct answer. The system provides feedback through LEDs and 7-segment displays and supports two different game modes.

## Features

- 10-bit binary values from **0 to 1023**
- Two gameplay modes
- Three-life system
- Score tracking
- Random number generation
- Binary input using physical switches
- Visual feedback using LEDs
- 7-segment display interface
- Success and error feedback
- Hint system in Mode 8
- Hardware reset functionality

## Game Modes

### Mode 0 — Standard

The player uses the FPGA switches to reproduce the binary representation of the displayed decimal number.

A correct answer increases the score and generates a new number. An incorrect answer removes one life while keeping the same number for another attempt.

### Mode 8 — Assisted

Mode 8 follows the same gameplay but provides additional feedback after an incorrect answer.

LEDs indicate which switch positions are already correct, helping the player identify errors in their binary representation.

## Technical Implementation

### Finite-State Machines

The game logic was implemented using **Moore finite-state machines (FSMs)**.

The main FSM controls:

- Mode selection
- Game initialization
- User input validation
- Success and error states
- Life management
- Score tracking
- Hint generation
- End-of-game behavior

A separate FSM was designed for pulse generation to ensure that a physical button press produces a single synchronized action.

### Synchronous Input Handling

Physical button presses can remain active for multiple clock cycles and may not be synchronized with the FPGA clock.

A dedicated pulse-generation module was therefore implemented to convert button presses into single synchronized pulses, preventing one press from triggering multiple game actions.

### FPGA I/O

The application interacts directly with the FPGA board through:

- **Switches** — binary number input
- **Push buttons** — mode selection, confirmation, and reset
- **LEDs** — binary input, remaining lives, and hints
- **7-segment displays** — numbers, game status, and score

## Architecture

The system is composed of several VHDL modules:

```text
FPGA Binary Training Game
│
├── FSM_CORE
│   └── Main game state machine
│
├── pulse_gen
│   └── Synchronized single-pulse generation
│
├── rng
│   └── Pseudo-random number generation
│
├── debounce
│   └── Button debouncing
│
├── gest_affichage
│   └── 7-segment display management
│
└── top_jeu_binaire
    └── Top-level module integrating the complete system
```

## Validation

The design was validated through both simulation and physical FPGA testing.

Testing covered:

- Both game modes
- Correct binary answers
- Incorrect binary answers
- Life decrement behavior
- Mode 8 hints
- Score calculation
- Game-over behavior
- Button input handling

The final design was successfully implemented and tested on the FPGA board.

## Technologies

- **VHDL**
- **FPGA**
- **Finite-State Machines**
- **Sequential Digital Logic**
- **AMD/Xilinx Vivado**

## Academic Context

**Course:** INF1500 — Digital Systems Logic  
**Institution:** Polytechnique Montréal  
**Team:** 2 students  
**Term:** Fall 2025

## Authors

- Mohamed Lamine Gueye
- Skander Jedidi

## Acknowledgements

Some support modules used by the project were provided as part of the INF1500 laboratory material, including the random number generator, debounce module, and 7-segment display management module.

The main game FSM, pulse-generation logic, system integration, and FPGA implementation were completed as part of the student project.

# Router_1X3

## 📌 Project Overview

This project implements the RTL design of a 1x3 packet router using Verilog HDL. It showcases a modular approach combining FIFO buffers, a Finite State Machine (FSM) controller, a synchronizer, and register logic. The router is designed to receive data from a single input port and route it to one of the three output ports based on the destination address embedded in the packet header.


## 🧱 Architecture

The design includes the following key components:
- **FIFO Buffers (3x)**: Temporary storage for each output port.
- **FSM Controller**: Governs routing decisions, read/write control, and system coordination.
- **Synchronizer**: Handles timing issues and maintains data integrity between modules.
- **Register Logic**: Captures and holds packet data, used in decision-making.

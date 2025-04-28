# Personal Hardware Projects
Some small, interesting hardware modules and corresponding test benches.

## FIFO
Queue (First-In-First-Out) data structure with configurable data bit width and size.

* Concurrent reads and writes are supported.
* Reads [Writes] on empty [full] are possible iff there is a concurrent write [read].

## UART
UART transmitter and receiver with configurable baud rate and end-to-end test bench.

* Currently 8 data, no parity, and 1 stop bit is used (8N1). Possibly extend to be configurable to different setups (5-9 data bits, optional parity bit, 1-2 stop bits).
* The receiver samples data bits in the middle of the interval.
* The receiver checks the low start bit again after half a baud interval of detecting it first. Otherwise, the hardware infrastructure of the channel and the behavior of the transmitter are assumed to be stable and conforming to UART specification.

## AXI-type Stream Normalizer (WORK-IN-PROGRESS)

### Background
* Consider an AXI-type stream with the usual `data` (of variable width), `last`, `ready`, and `valid` signals.
* Optionally, a `keep` signal indicates which bytes of the data are valid. Empty transmissions are not allowed.
* A stream is normalized if all but the last transmissions are fully valid.
* Consider a simplified (but realistic) situation where each transmission consists of a fully valid part followed by an invalid one. In this case, the keep signal can be replaced by a `cnt` representing the length of the valid part. `cnt` uses an implicit MSB (Most Significant Bit), i.e. `cnt = 0` means the transmission is fully valid.

In this setting, normalize a given stream.

### Implementation
* Use buffer to store overflowing data.
* Relay a transmission only when there is enough data (with existing overflow) to fill it.
* Possibly explore extending it to full AXI specification, i.e. general `keep` signal with any data byte being potentially invalid. Synthesizability and congestion might become a problem.
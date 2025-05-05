# Personal Hardware Projects
Some small, interesting hardware modules and corresponding test benches.

To simulate test benches, install Icarus Verilog: `sudo apt install iverilog`.

To test synthesizability use [sv2v](https://github.com/zachjs/sv2v) and Yosys.

## FIFO
Queue (First-In-First-Out) data structure with configurable data bit width and size.

* Concurrent reads and writes are supported.
* Reads [Writes] on empty [full] are possible iff there is a concurrent write [read].

## UART
UART transmitter and receiver with configurable baud rate and end-to-end test bench.

* Currently 8 data, no parity, and 1 stop bit is used (8N1). Possibly extend to be configurable to different setups (5-9 data bits, optional parity bit, 1-2 stop bits).
* The receiver samples data bits in the middle of the interval.
* The receiver checks the low start bit again after half a baud interval of detecting it first. Otherwise, the hardware infrastructure of the channel and the behavior of the transmitter are assumed to be stable and conforming to UART specification.

## AXI-type Stream Normalizer

### Background
* Consider an AXI-type stream with the usual `data` (of variable width), `last`, `ready`, and `valid` signals.
* Optionally, a `keep` signal indicates which bytes of the data are valid. Empty transmissions are not allowed (i.e. with `valid = 1` but `keep = 0`).
* A stream is normalized if all but the last transmissions are fully valid.
* Consider a simplified (but realistic) situation where each transmission consists of a fully valid part followed by an invalid one. In this case, the `keep` signal can be replaced by a `cnt` representing the length of the valid part. `cnt` uses an implicit MSB (Most Significant Bit), i.e. `cnt = 0` means the transmission is fully valid.

In this setting, normalize a given stream.

### Implementation
* Use buffer to store overflowing data.
* Relay a transmission only when there is enough data (with existing overflow) to fill it.
* Possibly explore extending it to full AXI specification, i.e. general `keep` signal with any data byte being potentially invalid. Synthesizability and congestion might become a problem.

## Bitonic Sorter

### Background
A bitonic sorter is a network sorting inputs of size n = 2^D with a recursive structure of depth D.
The recursion works as follows for depth parameter `d`, sorting direction `dir` and input size `n = 2^d`. `order[i, j, dir]` is a simple function ordering the two indices `i` and `j` according to `dir`.

* `sorter(d, dir) on [0, n[`
    * `if d = 1:`
        * `order(0, 1, dir)`
    * `else:`
        1. `sorter(d-1, dir) on [0, n/2[`
        2. `sorter(d-1, ~dir) on [n/2, n[`
        3. `merger(d, dir) on [0, n[`
* `merger(d, dir) on [0, n[`
    * `if d = 1:`
        * `order(0, 1, dir)`
    * `else:`
        1. `for (i in [0, n/2[) order(i, i + n/2, dir)`
        2. `merger(d-1, dir) on [0, n/2[`
        3. `merger(d-1, dir) on [n/2, n[`

### Implementation
The implementation allows for configurable value bit width and sorting direction (asc <> `DIRECTION = 0`; desc <> `DIRECTION = 1`).

Because the base case at depth 1 is a single comparison, this design allows for very high clock rates, possibly higher than a device might facilitate. For this reason, it can make sense to put the base case at a higher depth to reduce recursion (and pipeline stages and overall latency) and increase the number of comparisons done in a single cycle (critical path). The code for the base cases are AI generated from [optimal (where known) sorting networks](https://bertdobbelaere.github.io/sorting_networks_extended.html) for 2^d inputs.
Notice, that the merger implementation defers its base case to that of the sorter (which works because the behavior is the same), which means only the sorter needs to be modified.

### Performance
* The below table is performance data for varying base case depth.
* Latencies refer to the clock cycles needed to get the sorted outputs and were obtained through simulation; they match our expectations based on the pipeline stages given as `D(D+1)/2` where the stages are reduced as the base case is lifted.
* Maximal clock frequency was estimated by compiling the design for a Lattice ECP5-85k FPGA. Due to the limited size of that device, the estimation could only be done for depth 7 and 8 bit values. Unsurprisingly, the frequency drops for higher base cases, but it drops so much that even when taking into account the saved cycles, the overall temporal latency goes up significantly across the board from the standard base case at depth 1. It seems, the base case at depth 1 is the best choice so long as the device can operate at the maximum frequency.
* The deepest structure using 32 bit values that could be synthesized with ~35 GB of memory was at depth 9.

| Base case | Base case stages | Fmax D=7, 8 bit | Latency D=7       | Logic blocks D=7, 8 bit | Logic blocks D=9, 32 bit |
|:----------|:-----------------|:----------------|:------------------|:------------------------|:-------------------------|
| 1         | 1                | 181 MHz (155ns) | 28 cycles (155ns) | 54785                   | 5530761                  |
| 2         | 3                | 91 MHz (231ns)  | 21 cycles (231ns) | 49838                   | 1985182                  |
| 3         | 6                | 46 MHz (327ns)  | 15 cycles (327ns) | 48877                   | 2352990                  |
| 4         | 9                | 26 MHz (385ns)  | 10 cycles (385ns) | 85630                   | 2476214                  |
| 5         | 14               | 16 MHz (375ns)  | 6 cycles (375ns)  | 100908                  | 2617115                  |
| 6         | 20               | 11 MHz (273ns)  | 3 cycles (273ns)  | 92651                   | 2813321                  |

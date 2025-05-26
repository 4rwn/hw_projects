# Personal Hardware Projects

Some small, interesting hardware modules and corresponding test benches.

To simulate test benches, install Icarus Verilog.

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
| 1         | 1                | 181 MHz         | 28 cycles (155ns) | 54785                   | 5530761                  |
| 2         | 3                | 91 MHz          | 21 cycles (231ns) | 49838                   | 1985182                  |
| 3         | 6                | 46 MHz          | 15 cycles (327ns) | 48877                   | 2352990                  |
| 4         | 9                | 26 MHz          | 10 cycles (385ns) | 85630                   | 2476214                  |
| 5         | 14               | 16 MHz          | 6 cycles (375ns)  | 100908                  | 2617115                  |
| 6         | 20               | 11 MHz          | 3 cycles (273ns)  | 92651                   | 2813321                  |

## RISC-V Processor Core

This is an implementation of an execution core for the RISC-V instruction set.

### First Implementation

The first working version supports just the base RV32I instruction set and uses a 5 stage pipeline:

* IF: Instruction fetch from instruction memory
* ID: Instruction decoding and register reads
* EX: Execute compute operation using an ALU and evoke potential control flow transfers
* MEM: Read/Write data memory
* WB: Write-back result to destination register

Aside from a clock and reset signal, the top-level module connects through its port to the read-only instruction memory and the data memory. The design can be synthesized for an iCE40 FPGA using 4685 logic cells and has a maximal frequency of 54.59 MHz after PnR.

Note that the use of open-source tools for simulation and synthesis means that structs or interfaces are not necessarily supported. For this reason, I had to use individual, explicit signals (for example for the different pipeline stages) where a more neat structure would be desirable.

#### Data hazards

A pipelined design leads to some correctness pitfalls that require addressing. For one, a source register can be read for an instruction at ID when an earlier instruction has not yet gotten the chance to write it during WB. To avoid reading an old register value, the simplest solution is to stall the pipeline stages up to and including ID when it is detected that one of the source registers is equal to the destination register of the instruction currently in EX, MEM, or WB. Those three pipeline stages keep executing normally and after at most 3 cycles the required register will have been written and the instruction stalled in ID can proceed.

#### Flushing instructions on control flow transfer

A similar consequence of the pipelined design as data hazards is the fact that at the time when the decision is made to take a branch, 3 more instructions are already in the pipeline. In this case, there is nothing to do but flush those 3 invalid instructions. We implement this by simply invalidating all the instructions in the previous stages of the pipeline.

### Register Forwarding

#### Background

Stalling a register read for 3 cycles if it immediately follows a write of the same register is hugely inefficient, especially considering that the result that will be written in WB is already available after EX. A desirable optimization would thus be to forward result values from the EX or MEM stages to ID in order to limit stalled cycles. If done correctly, this should completely avoid stalling in all cases but one: Reading a register for an instruction that immediately followed a memory load on the same register will still require a stall cycle because the stage where the value is needed and the one where it is ready are 2 apart.

#### Implementation

My thinking in the section above turned out to be slightly wrong: stalling is still required in many cases with only register forwarding. When a register is needed that was written by the previous instruction (say an `add`), that instruction is currently in EX and the result that is needed for ID will only be available at the end of this cycle, meaning decoding can only take place in the next one. In this case, one stalled cycle is needed as opposed to 3 without register forwarding.

Looking at two dependent instructions which immediately follow one another, we can say the following about the required stalling depending on the type of the earlier instruction: A `lui` instruction incurs no stalling (because its result is immediately available after ID in the immediate), a load instruction incurs 2 stalled cycles (because its result is only available after MEM) and everything else 1 (because the result is available after EX, as described above). All of these cases resulted in 3 stall cycles previously.

Adding register forwarding from the ID, EX, and MEM stages to the ID stage resulted in the usage of 4968 logic cells (+6%) and a reduced maximal clock frequency of 50.65 MHz (-7.8%).

### Register Reading Stage

I deepend the pipeline with another stage for register reading (RR) between ID and EX. The effects are somewhat peculiar: While Fmax is only minimally improved to 51.03 MHz (+0.8%), the design now uses just 2658 logic cells (-46.5%). I rewrote the flushing logic on branches and jumps and some other things at the same time though, so that might be playing into this.

Of course, adding this new stage has the downside that one more instruction has to be flushed on a branch or jump.

### Dedicated ALU Stage

Seeing that the RR stage by itself did not do much for Fmax and the critical path involved the adder in EX, I moved the Arithmetic Logic Unit to its own stage (ALU). The result uses a little more resources at 2841 logic cells (+6.9%) but has an Fmax of a whopping 74.13 MHz (+45.3%).

Because the computation result is now known one stage later (and one further away from RR), instructions that depend on an earlier one (that is not a `lui`) stall for one cycle longer than before.

### Single-cycle Multiplication Extension

To see the effects on area and frequency, I extended the design to support the RV32M instructions set including multiplication, division and remainder operations. I did so in the simplest possible way, by letting the synthesizer decide on a single-cycle implementation, basically treating these complex operations just like any other simpler one. Unsurprisingly, the results were nothing short of catastrophic: The core used 33177 logic cells (11.6x) at which point it was of course too large to be routed for an iCE40 FPGA, but it can be suspected that it would wreak havoc on the clock frequency as well.

I undid this change again because it is not sensible by any stretch of the imagination, the respective Git commit is TODO.

### Future Work

* Branch prediction: There are ways to limit the amount of work that is lost as a result of instructions having to be flushed in branching. By only diverting control flow after EX we incur the maximal penalty on each jump and branch instruction. Different kinds of instructions can be optimized differently in this regard: A JAL can be pre-decoded during IF and the jump executed for the next fetch, avoiding completely having to flush anything. A JALR cannot be dealt with in the same way because the jump address depends on a source register, but these jump instructions are mainly used for function calls and returns and thus are not as performance critical anyway. On the other hand, branches are very important for performance and a branch predictor can offer many benefits. It works in the IF stage and tries to anticipate whether a branch will be taken solely based on its address.
* Extend supported instruction set to multiplications/divisions or floating-point operations.

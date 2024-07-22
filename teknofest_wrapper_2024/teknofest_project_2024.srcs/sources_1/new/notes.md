- it seems that both data and instructions will be sent to the processor over UART
    - do they expect our processor to be on the ready, expecting instructions over UART, those should get written to program memory, and then get executed?
    - does that mean that we would have to write our own instructions that do this?
    - can we allow UART to write directly to program memory?, if not, can a program we write actually access program memory directly? doesn't that seem completely insecure?
- why are there seemingly 2 ram modules?


# Benchmarking
- we should find and use many benchmarks and test our processor with them, the spec mentions CoreMark

# File notes: teknofest_memory.sv
## SRAM
SRAM quite simply is a standard verilog memory array (instantiated at line 93):
```verilog
parameter MEM_DEPTH = 16 // Only valid for SRAM/
logic [127:0] memory [MEM_DEPTH-1:0];
```
this one does not use UART, we can use it to test the core on it's own without the uart functionality, this is good
it also doesn't use that ip memory block, that one is connected to the uart and is much slower I think
the ip memory block is only used when not using sram

# Memory controller notes
## wsize
0:byte, 1:half, 2:word
- Memory controller expects data to be placed at the beginning of the 32-bit input, so if we are sending 1-byte, wherever this byte might have been originally, here it must be place at the beginning of the input word, then I infer from the address you gave me where I should place this byte
- Same for the 2-byte case, you place the 2-bytes at the beginning of the input word

# Peripherals Notes
- Memory maps should be designed to require only 32-bit memory accesses
    - so you only use word write/read
- We should write a program the checks the uart in an infinite loop, reads instructions from it and executes them then goes back to checking the uart and so on, this way we can continuously control the processor through the uart port
- remember that we have memory-mapped io, meaning that the core interacts with io (uart) using a group of addresses in memory
    - so if the core is reading/writing one of the io-dedicated addresses, the memory controller needs to intercept 
    - so the memory controller should intercept any memory operation headed to an io-dedicated address and divert it to io control registers instead of caches or main memory

# Program to run infinitely on processor
(note only use word read/writes with memory-map according to spec)
1. write word `uart_ctrl`
    - set tx_en to 0 (not sending data initially)
    - set rx_en to 1 (to receive instructions)
    - set baud_div to some value
2. create var `byte_num` with initial value 0
3. read word `uart_status`
    - gives us the values: 
                        - `tx_full`
                        - `tx_empty`
                        - `rx_full`
                        - `rx_empty`
4. if not `rx_empty` then go to 4., else go to 2.
5. read word `uart_rdata` and place in instruction memory
    - you place it right afterward so it executes next
    - you place it at a byte address incremented by `byte_num` so after we write 4 times we end up with a full instruction which is a word long
6. increment `byte_num`
7. if `byte_num` is greater than or equal to 4 go to 5., else go to 4.
6. execute whatever instruction was read from `uart_rdata`
    - it should be in this data mem address
7. go to 2.

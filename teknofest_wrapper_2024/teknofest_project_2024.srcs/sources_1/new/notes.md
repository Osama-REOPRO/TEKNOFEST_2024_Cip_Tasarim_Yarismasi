- it seems that both data and instructions will be sent to the processor over UART
    - do they expect our processor to be on the ready, expecting instructions over UART, those should get written to program memory, and then get executed?
    - does that mean that we would have to write our own instructions that do this?
    - can we allow UART to write directly to program memory?, if not, can a program we write actually access program memory directly? doesn't that seem completely insecure?
- why are there seemingly 2 ram modules?


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

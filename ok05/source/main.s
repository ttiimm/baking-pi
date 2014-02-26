/* 
*    main.s - a solution to Baking Pi ok05 lesson: SOS 
*    
*    Blink the OK LED in an SOS pattern.
*/

.section .init
.global _start
_start:
    b       main

.section .text
main:
    @ The text section is stored after the init (0x8000) section in memory due to
    @ the way the makefile and linker scripts work. Here is what memory looks
    @ like:
    @
    @            __________________
    @           |      .text       |
    @           --------------------
    @   0x8000  |      .init       |
    @           --------------------
    @           |(bottom)          |
    @           |                  |
    @           |      Stack       | 
    @           |                  | 
    @   0x???   |(top)             |
    @           -------------------- 
    @           |      ATAGs       |
    @   0x100   |    (RPi info)    |
    @           --------------------
    @   0x0     |    loader stub   |
    @           -------------------- 
    @
    mov     sp, #0x8000

    @ Enable output on OK LED
    pinNum  .req r0
    pinFunc .req r1
    mov     pinNum, #16
    mov     pinFunc, #1
    bl      SetGpioFunction
    .unreq  pinNum
    .unreq  pinFunc

    @ Load the pattern into r4
    ptrn .req r4
    ldr     ptrn, =pattern
    ldr     ptrn, [ptrn]
    @ Load 0s into r5
    seq .req r5
    mov     seq, #0

    @ Label to loop on in order to turn LED on and off 
    loop$:
    
    pinNum  .req r0
    pinFunc .req r1
    mov     pinNum, #16
    
    @ Move the next sequence of pattern into pinFunc
    mov     pinFunc, #1
    lsl     pinFunc, seq
    and     pinFunc, ptrn
    bl      SetGpio
    .unreq  pinNum
    .unreq  pinFunc

    @ Wait for 1 seconds = 1,000,000 microseconds
    toWait .req r0
    ldr     toWait, =1000000
    bl      Wait
    .unreq  toWait

    @ Iterate the sequence by 1 and and it by 11111. Since the pattern has is 
    @ anding with 11111, it will return 0, setting sequence back to start.
    add     seq, #1
    and     seq, #0b11111

    @ Repeat
    b loop$

.section .data
@ this makes sure the address of the next line is a multiple of 2^2 = 4.
@ This is required as the ldr instruction must read memory that are multiples
@ of 4.
.align 2
pattern:
    @ The SOS pattern, 0 for off and 1 for on. Each iteration of the loop will
    @ load one of these values in and turn off or on the LED based on the value.
    .int 0b11111111101010100010001000101010

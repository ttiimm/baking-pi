/* 
*    main.s - a solution to Baking Pi ok04 lesson: Precision 
*        
*
*    All functions related to GPIO have been moved into an accompanying file:
*    gpio.s.
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

    @ Label to loop on in order to turn LED on and off 
    loop$:
    
    @ Turn the pin off, thus enabling the LED
    pinNum  .req r0
    pinFunc .req r1
    mov     pinNum, #16
    mov     pinFunc, #0
    bl      SetGpio
    .unreq  pinNum
    .unreq  pinFunc

    @ Wait for 2 seconds = 2,000,000 microseconds
    toWait .req r0
    ldr     toWait, =2000000
    bl      Wait
    .unreq  toWait

    @ Turn the pin on, thus disabling the LED
    pinNum .req r0
    pinFunc .req r1
    mov     pinNum, #16
    mov     pinFunc, #1
    bl      SetGpio
    .unreq  pinNum
    .unreq  pinFunc

    @ Wait for 1 seconds = 1,000,000 microseconds
    toWait .req r0
    ldr     toWait, =1000000
    bl      Wait
    .unreq  toWait

    @ Repeat
    b loop$

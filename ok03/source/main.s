/* 
*    main.s - a solution to Baking Pi ok03 lesson: functions 
*        
*    Turn a Raspberry PI LED on and off using the Application Binary Input 
*    (ABI) standard and procedure calls.  >>>>>IVT
*    
*    The ABI requires that function arguments are passed in registers r0, r1, r2,
*    and r3. The registers r4-r12 must have the same values after the function
*    returns. A return value will be stored in registers r0 and r1. The stack
*    is also used for passing arguments into a function and has a special register,
*    sp, designated for it.  There are also push and pop instructions for getting
*    values onto the stack and back off.
*    
*    The link register (lr) will hold the address to return to after the function
*    exits.
*
*    All functions related to GPIO have been moved into an accompanying file:
*    gpio.s.
*/

.section .init
.global _start
_start:
    b      main

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
    mov    sp, #0x8000

    @ Enable output on OK LED
    pinNum .req r0
    pinFunc .req r1
    mov    pinNum, #16
    mov    pinFunc, #1
    bl     SetGpioFunction
    .unreq pinNum
    .unreq pinFunc

    @ Label to loop on in order to turn LED on and off 
    loop$:
    
    @ Turn the pin off, thus enabling the LED
    pinNum .req r0
    pinFunc .req r1
    mov    pinNum, #16
    mov    pinFunc, #0
    bl     SetGpio
    .unreq pinNum
    .unreq pinFunc

    @ Busy wait
    @
    @ Set r2 to a large integer, then loop untile decremented to 0.
    mov r2,#0x3F0000
    wait1$:
        sub r2,#1
        cmp r2,#0
        bne wait1$

    @ Turn the pin on, thus disabling the LED
    pinNum .req r0
    pinFunc .req r1
    mov    pinNum, #16
    mov    pinFunc, #1
    bl     SetGpio
    .unreq pinNum
    .unreq pinFunc

    @ Busy wait
    @
    @ Set r2 to a large integer, then loop untile decremented to 0.
    @ @ttiimm - some way to not duplicate this code?
    mov r2,#0x3F0000
    wait2$:
        sub r2,#1
        cmp r2,#0
        bne wait2$

    @ Repeat
    b loop$

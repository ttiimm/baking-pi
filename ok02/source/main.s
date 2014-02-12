/* 
*    main.s - a solution to Baking Pi ok02 lesson 
*        Turn a Raspberry PI LED on and off.
*    
*    Our register use is as follows:
*    r0=0x20200000 the address of the GPIO region.
*    r1=0x00040000 a number with bits 18-20 set to 001 to put into the GPIO
*                  function select to enable output to GPIO 16. 
*    then
*    r1=0x00010000 a number with bit 16 high, so we can communicate with GPIO 16.
*    r2=0x003F0000 a number that will take a noticeable duration for the processor 
*                  to decrement to 0, us allowing to create a delay.    
*/

.section .init
.global _start
_start:
    @ the address of GPIO
    ldr  r0, =0x20200000

    @ Enable output to 16th GPIO pin
    @
    @ There are 24 bytes in the CPIO controller. The 
    @ first 4 relate to the first 10 GPIO pins, second 4
    @ relate to next 10 and so on. There are 54 GPIO pins, so
    @ we need 6 sets of 4 bytes, which is 24 total bytes.
    @ Since we want 16th GPIO pin for the LED, we need the 
    @ second set of 4 bytes (10-19) and we need the 6th set
    @ of 3 bits, which is where #18 (6 * 3) comes from.
    mov  r1, #1
    lsl  r1, #18
    str  r1, [r0, #4]
    
    @ Set the 16th bit of r1    
    mov  r1, #1
    lsl  r1, #16

    @ Label to loop on in order to turn LED on and off 
    loop$:

    @ Turn on LED
    @
    @ Store 16 in the GPIO controller address + 40.  I guess
    @ 40 is a special address to turn a pin off.
    str  r1, [r0, #40]

    @ Busy wait
    @
    @ Set r2 to a large integer, then loop untile decremented to 0.
    mov r2,#0x3F0000
    wait1$:
        sub r2,#1
        cmp r2,#0
        bne wait1$

    @ Turn off LED
    @
    @ Set GPIO 16 to high, causing the LED to turn off.
    str r1,[r0,#28]

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

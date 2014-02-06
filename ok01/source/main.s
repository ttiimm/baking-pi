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

    @ Turn on LED
    @
    @ Store 16 in the GPIO controller address + 40.  I guess
    @ 40 is a special address to turn a pin off.
    mov  r1, #1
    lsl  r1, #16
    str  r1, [r0, #40]

    @ Loop forever
    loop$:
    b loop$

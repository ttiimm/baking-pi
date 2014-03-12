/* 
*   gpio.s - a library of GPIO related functions 
*/


/*
*   GetGpioAddress - get the address of the GPIO controller
*
*   returns:
*       r0 - the address of the GPIO controller
*/
.globl  GetGpioAddress
GetGpioAddress:
    ldr   r0, =0x20200000
    mov   pc, lr


/*
*   SetGpioFunction - set the function of a GPIO pin
*
*   args:
*       r0 - the GPIO pin
*       r1 - the function
*/
.globl  SetGpioFunction
SetGpioFunction:
    @ There are 54 GPIO pins: 0-53
    cmp    r0, #53
    @ Each pin has 8 functions: 0-7
    @ The suffix ls, lower same, on a command only executes if in the last comparison 
    @ the first value is less than or equal to the second. Do not confuse with
    @ le, less than equal, suffix.
    @
    @ So this line only executes if GPIO pin argument is <= 53.
    cmpls  r1, #7
    @ The suffix hi only executes if the last comparison was higher. Do not confuse
    @ with gt, greater, suffix.
    @
    @ Thus, if either 0 <= r0 <= 53 or 0 <= r1 <= 7 is not true, then return early.
    movhi  pc, lr
    @ Copy lr to top of the stack. Note only general purpose registers and lr
    @ can be pushed.
    push   {lr}
    @ Move the first argument out of the way.
    mov    r2, r0
    bl     GetGpioAddress

    @ Set the correct GPIO pin by determining its address relative to the GPIO
    @ address. 
    @
    @ The GPIO controller uses 24 bytes to interact with its pins. The first 4
    @ relate to the first 10 GPIO pins, the second 4 relate to the next set, and
    @ so on. Since there are 54 GPIO pins, there needs to be 6 sets of 4 bytes,
    @ which is where the 24 bytes comes from.
    @
    @ This loop will set r0, at the beginning the address of GPIO controller,
    @ to the address of the pin's function settings. Additionally, r2 will now
    @ hold the remainder of r2 / 10, the 10 comes from the fact that pins are
    @ in groups of 10.
    @
    @ Altogether this loop will perform:
    @       r2 = r2 % 10
    @       r0 = GPIO controller address + 4 * (GPIO Pin Number / 10)
    functionLoop$:
        cmp    r2, #9
        subhi  r2, #10
        addhi  r0, #4
        bhi    functionLoop$

    @ Now need to determine what value to set at r0. This is determined by taking
    @ r2, the remainder of the GPIO pin % 10, multiplying it by 3, and left shifting
    @ the function number by this amount. Notice that this will reset all the
    @ pins in this block to 0 except for the pin set. This would be inefficient
    @ if the system made heavy use of the GPIO pins.
    @
    @ Multiply r2 by 3 through a left shift and addition (r2 * 3 = r2 + r2 * 2)
    add    r2, r2, lsl #1
    lsl    r1, r2
    str    r1, [r0]

    @ Return from the function call by setting pc to lr, which had been stored
    @ on the stack.
    pop    {pc}


/*
*   SetGpio - set a GPIO pin on or off
*
*   args:
*       r0 - pinNum - the pin number
*       r1 - pinVal - whether to turn on (not 0) or off (0)
*/
.globl SetGpio
SetGpio:
    @ <alias> .req <register>
    pinNum .req r0
    pinVal .req r1
    
    @ Validate that pinNum is <= 53 
    cmp    pinNum, #53
    movhi  pc, lr
    push   {lr}

    @ pinNum is now stored in r2
    mov    r2, pinNum
    .unreq pinNum
    pinNum .req r2

    @ get gpioAddress
    bl GetGpioAddress
    gpioAddress .req r0
    
    @ The GPIO controller has two sets of 4 bytes used for turning pins on and
    @ off.
    pinBank .req r3
    @ To determine which set of pins pinNum is in, the first or second of the 32
    @ bits of pins. To accomplish this, we divide pinNum by 32, which is the 
    @ same as a right shift by 5.
    lsr    pinBank, pinNum, #5
    @ Since the the sets are of 4 bytes each, multiply by 4.
    lsl    pinBank, #2
    @ gpioAddress == 0x20200000 if pin number is 0-31 or 0x20200004 if the pin is
    @ number 32-53. So if we add 28 the address is set to turn pin on and if we
    @ add 40 the address is set to turn the pin off.
    add    gpioAddress, pinBank
    .unreq pinBank

    @ Need a bit set of the pinNum % 32, this is accomplished by taking the boolean
    @ and of pinNum and 32 - 1 = 31.
    and    pinNum, #31
    setBit .req r3
    mov    setBit, #1
    lsl    setBit, pinNum
    .unreq pinNum

    teq    pinVal, #0
    .unreq pinVal
    streq  setBit, [gpioAddress, #40]
    strne  setBit, [gpioAddress, #28]
    .unreq setBit
    .unreq gpioAddress
    pop    {pc}

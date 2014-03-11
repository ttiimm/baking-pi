/* 
*   timer.s - a library of time related functions
*
*   The Timer increments the Counter by 1 every 1 microsecond. On each increment,
*   the Timer also compares the lowest 32 with the comparison registers and updates
*   the Status address.
*
*   Address     Size / Bytes    Name            Description              Read or Write
*   20003000    4               Status          Register used to         RW
*                                               control and clear timer
*                                               channel comparator 
*                                               matches.    
*   20003004    8               Counter         A counter that           R
*                                               increments at 1MHz.
*   2000300C    4               Compare 0       0th Comparison register  RW
*   20003010    4               Compare 1       1st Comparison register  RW
*   20003014    4               Compare 2       2nd Comparison register  RW
*   20003018    4               Compare 3       3rd Comparison register  RW 
*
*   The timer functions in this library will be written based off of these registers.
*/


/*
*   GetSystemTimerBase - get the address of the System Timer
*
*   returns:
*       r0 - the address of the Timer
*/
.globl GetSystemTimerBase
GetSystemTimerBase:
    ldr     r0, =0x20003000
    mov     pc, lr


/*
*   GetTimeStamp - get the Counter's value
*
*   returns:
*       Since the Counter value is 8 bytes, the return value is split across two
*       registers.
*       r0 - the lower part of the 8 byte Counter value
*       r1 - the higher part of the 8 byte Counter value
*/
.globl GetTimeStamp
GetTimeStamp:
    push    {lr}
    bl      GetSystemTimerBase
    @ Load 8 bytes into r0, r1 starting at [r0, #4], r0 + 4. Since r0 contains 
    @ the timer base address, so r0 + 4 is the counter register. Note that r0
    @ is the low register and r1 is the high register.
    ldrd    r0, r1, [r0, #4]
    pop     {pc}


/*
*   Wait - wait for specified number of microseconds
*
*   The wait is implemented by checking the value of the Counter, adding amount
*   of time to wait, and then branching until greater than the sum.
*
*   args:
*       r0 - the amount of time to wait in microseconds
*/
.globl Wait
Wait:
    delay .req r2
    mov     delay, r0
    push    {lr}
    bl      GetTimeStamp
    start .req r3
    mov     start, r0
    @ branch until the elapsed time is greater than the amount of time to delay
    loop$:
        bl      GetTimeStamp
        elapsed .req r1
        sub     elapsed, r0, start
        cmp     elapsed, delay
        .unreq  elapsed
        bls     loop$
    .unreq  delay
    .unreq  start
    pop     {pc}

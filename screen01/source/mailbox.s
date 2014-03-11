/* 
*   mailbox.s - a library for sending messages between devices.
*/


/*
*   GetMailboxBase - get the base address of the mailbox region of memory 
*
*   returns:
*       r0 - the base address of the mailbox
*/
.globl  GetMailboxBase
GetMailboxBase:
    ldr     r0, =0x2000B880
    mov     pc, lr


/*
*   MailBoxWrite - write a message to a mailbox
*
*   args:
*       r0 - the message is in the top 28 bits of r0
*       r1 - the mailbox channel 
*
*/
.globl  MailBoxWrite
MailBoxWrite:
    @ only the top 28 bits of r0 can be set
    tst     r0, #0b1111
    movne   pc, lr
    @ check that r1 is a valid mailbox
    cmp     r1, #15
    movhi   pc, lr
    channel .req r1
    value .req r2
    mov     value, r0
    push    {lr}
    bl      GetMailboxBase
    mailbox .req r0

    wait1$:
        status .req r3
        @ why 18 here?
        ldr     status, [mailbox, #0x18]
        @ why and status with 0x80000000? This needs to keep looping until top
        @ bit of status field is set, but not sure where value comes from.
        tst     status, #0x80000000
        .unreq  status
        bne     wait1$

    @ store values in single register
    add     value, channel
    .unreq  channel
    @ store into write mailbox
    str     value, [mailbox, #0x20]
    .unreq  value
    .unreq  mailbox
    pop     {pc}


/*
*   MailBoxRead - read a message from a mailbox
*
*   args:
*       r0 - which mailbox to read from
*
*   returns:
*       r0 - the message
*/
.globl  MailBoxRead
MailBoxRead:
    cmp     r0, #15
    movhi   pc, lr
    channel .req r1
    mov     channel, r0
    push    {lr}
    bl      GetMailboxBase
    mailbox .req r0

    rightmail$:
        @ check until read is ready
        wait2$:
            status .req r2
            @ the 30th bit of status must be set to 0
            ldr     status, [mailbox, #0x18]
            tst     status, #0x40000000
            .unreq  status
            bne     wait2$

        @ read the mail
        mail .req r2
        ldr     mail, [mailbox, #0]

        inchan .req r3
        @ check if the message is addressed to the correct channel
        and     inchan, mail, #0b1111
        teq     inchan, channel
        .unreq  inchan
        bne     rightmail$
        .unreq  channel
        .unreq  mailbox

        @ put the message into r0 to return
        and     r0, mail, #0xfffffff0
        .unreq  mail
        pop     {pc}

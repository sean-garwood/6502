notes on hw interrupts from ben eater

2 things:

- trigger
- subroutine

## trigger interrupt

2 methods to trigger:

1. pin4: irq\ interrupt request
2. pin6: nmi\ non-maskable interrupt

these are tied +5v as of 6/19/26

## code to run

Need to place at the reset vector. see [table 3-1 vector
locations](./todo)

### vector locs

fffc/d have first bit of code to execute when the resb pin
goes logic 0)

## interrupt ops

1. setting flag within **interrupt flag register (IFR)**
1. enable interrupt by corresponding bit in the **interrupt enable
   register (IER)**
1. signaling microprocessor using IRQ\

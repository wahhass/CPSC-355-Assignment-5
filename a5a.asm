// Wahaj Hassan
// CPSC 355 - Assignment 5
// Student ID: 10136892

.global     top, stack                                                      // top and stack are the global variables.

.section    ".text"

define(STACKSIZE, 5)                                                        // Defining stack size to 5.
define(FALSE, 0)
define(TRUE, 1)

stackOvflw: .string  "\nStack overflow// Cannot push value onto stack.\n"   // Stack Overflow error message.
            .align  4

stackUnflw: .string  "\nStack underflow// Cannot pop an empty stack.\n"     // Stack Underflow error message.
            .align  4

stkIsEmpty: .string  "\nEmpty stack\n"                                      // Stack is empty for the display.
            .align  4

stkContent: .string  "\nCurrent stack contents:\n"                          // First line of the display output.
            .align  4

prtContent: .string  "  %d"                                                 // Printing elements of stack.
            .align  4

lineBreak:  .string  "\n"                                                   // Line Break for the after display output.
            .align  4

topStack:   .string  " <-- top of stack"                                    // Indicating element on top of stack.
            .align  4

beginPush                                                                   // Pushing a new element on top of stack.

            call stackFull                                                  // Checking if the stack is already full.
            nop

            cmp     w21,TRUE                                                // Is it (stack) already full? 
            be      fullError                                               // If yes, branch to the fullError.
            nop                                                             // Or else, proceed ahead.

            adrp    w21, top                                                // Gettingting the address of top into w21.
            add     w21, w21, :lo12:top      

            ld      [w21], w10                                              // Loading value of top into w10.

            inc     w10                                                     // Stack has grown by 1.
            st      w10, [w21]                                              // Updating value of top.
            sll     w10, 2, w10                                             // Multiply top by 4 for offset to access stack memory.

            adrp     w9, stack                                              // Getting the address of stack in memory.
            add      w9, w9, :lo12:stack    

            str      w1, [w9 + w10]                                         // Storing the new value on the stack.

            ba      pushDone                                                // Done pushing.
            nop

fullError:  set     stackOvflw, w21                                         // Prepare Overflow error message.
            call    printf                                                  // Printing overflow eror message.
            nop

pushDone:   clr     w21                                                     // Done pushing, clear registers used.
            clr     w9
            clr     w10
endPush


beginPop                                                                    // Pops an element off the stack.
            call    stackEmpty                                              // Checking if the stack is already empty.
            nop

            cmp     w21, TRUE                                               // Is the stack already empty?
            be      emptyError                                              // If it is, branch to emptyError.
            nop                                                             // Or else, proceed.

            adrp    w21, top                                                // Loading address of top into w21.
            add     w21, w21, :lo12:top

            ldr     [w21], w10                                              // Loading value of top into w10

            sll     w10, 2, w11                                             // Getting offset of top element on stack into w11.

            adrp    w9, stack                                               // Loading the value of the top element on stack.
            adrp    w9, w9, :lo12:stack

            ld      [w9 + w11],w1                                           // Loading that value into return input register.

            dec     w10                                                     // Decreasing top by 1.
            str     w10, [w21]                                              // Updating top in memory.

            ba      donePop                                                 // Done popping.
            nop

emptyError: set     stackUnflw, w21                                         // Preparing Underflow error message.
            call    printf                                                  // Printing Underflow error message.
            nop

donePop:    clr     w21                                                     // Done popping, clearing registers used.
            clr     w9
            clr     w10
            clr     w11
endPop


beginStackFull                                                              // Checking if the stack is already full.
            adrp   w21, top                                                 // Loading address of top into w21.
            add    w21, w21, :lo12:top

            ld      [w21], w10                                              // Loading value of top into w10.

            mov     STACKSIZE, w15                                          // Moving maximum stack size into w15.

            sub     w15, 1, w11                                             // Max Stack size -1 to compare with top.

            cmp     w10, w11                                                // Does top = STACKSIZE?
            be      ifFULL                                                  // If it does, branch to ifFULL.
            nop                                                             // Or else, proceed.

            mov     FALSE, w1                                               // Returning FALSE.

            ba      doneFull                                                // Branching to doneFull.
            nop

ifFULL:     mov     TRUE, w1                                                // Returning TRUE and proceed to doneFULL.

doneFull:   clr     w21                                                     // Done checking, clear registers used.
            clr     w10
            clr     w11
            clr     w15
endStackFull


beginStackEmpty                                                             // Checking if the stack is already empty.
            adrp   w21, top                                                 // Loading address of top into w21.
            add    w21, w21, :lo12:top

            ld      [w21], w10                                              // Loading value of top into w10.

            mov     -1, w11                                                 // Mov -1 into w11 to compare with top.

            cmp     w10, w11                                                // Seeing if top = -1
            be      ifEMPTY                                                 // If it does, branch  it to ifEMPTY.
            nop

            mov     FALSE, w1                                               // Or else, stack won't be empty so return FALSE.

            ba      doneEmpty                                               // Branching it to doneEmpty.
            nop

ifEMPTY:    mov     TRUE, w1                                                // Stack is empty so return TRUE.

doneEmpty:  clr     w21                                                     // Done checking, clearing registers used.
            clr     w10
            clr     w11
            
endStackEmpty


beginDisplay                                                                // Checking if stack is empty.
            call    stackEmpty
            nop

            cmp     w21, TRUE                                               // If it is, branch it to isEmpty.
            be      isEmpty
            nop

            set     stkContent, w21                                         // Or else, print the initial line for the displaying.
            call    printf
            nop

            adrp   w10, top                                                 // Loading address of top into w10.
            add    w10, w10, :lo12:top

            ld     [w10], w10                                               // Loading value of top into w10, call it i. Will be used to traverse.

            adrp   w11, stack                                               // Loading address of stack into w11.
            add    w11, w11, :lo12:stack

            mov     w10, w13                                                // Saving value of top for comparing

loop:       cmp     w10, 0                                                  // Is i still less than or equal to 0?
            bl      doneDisp                                                // if it isn't, branch to doneDisp.
            nop

            sll     w10, 2,  w12                                            // Multiply i by 4 and store in w12 for offset to access stack.

            ld      [w11 + w12], w9                                         // Loading the value in the stack at that index to w9 for printing.

            set     prtContent, w21                                         // Loading print statement to w21.
            call    printf                                                  // Printing the stack element.
            nop

            cmp     w10,  w13                                               // Checking if i = top.
            be      printTop                                                // If it is, branch to printTop.
            nop

            dec     w10                                                     // Decrementing index i by 1.

            set     lineBreak, w21                                          // Printing a line break character.
            call    printf
            nop

            ba      loop                                                    // Going back to the loop.
            nop

printTop:   set     topStack, w21                                           // i is top. Setting output string to w21.
            call    printf                                                  
            nop

            dec     w10                                                     // Decrementing index by 1.

            set     lineBreak, w21                                          // Printing a line break character.
            call    printf
            nop

            ba      loop                                                    // Going back to the loop.
            nop

isEmpty:    set     stkIsEmpty, w21                                         // Stack is empty. Setting corresponding output string to w21.
            call    printf                                                  // Printing the string "Empty stack"
            nop

doneDisp:   clr     w21                                                     // Done displaying. Clearing the registers used.
            clr     w9
            clr     w10
            clr     w11
            clr     w12
            clr     w13
endDisplay
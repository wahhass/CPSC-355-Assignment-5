// Wahaj Hassan
// CPSC 355 - Assignment 5
// Student ID: 10136892

date:           .asciz  "%s %s%s, %s\n"                         // Output for valid input. MM DD YYYY format .
                .align  4                                       // Memory alignment.

argumentsBad:   .asciz  "Usage: mm dd yyyy\n"                   // Output for wrong number of arguments.
                .align  4                                       // Memory alignment.

monthBad:       .asciz  "Provided month is out of bounds.\n"    // Output for invalid month argument.
                .align  4                                       // Memory alignment.

dayBad:         .asciz  "Provided day is out of bounds.\n"      // Output for invalid day argument.
                .align  4                                       // Memory alignment.

yearBad:        .asciz  "Provided year is out of bounds.\n"     // Output for invalid year argument.
                .align  4                                       // Memory alignment.

.align      4                                                   // Memory alignment.
.section    ".data"                                             // New data section for an array of months.


            month:  .word   JA_m, FB_m, MA_m, AP_m, MY_m, JN_m, JL_m, AU_m, SE_m, OC_m, NV_m, DE_m

            JA_m:   .asciz  "January"                           // Months name for output Strings.
            FB_m:   .asciz  "February"
            MA_m:   .asciz  "March"
            AP_m:   .asciz  "April"
            MY_m:   .asciz  "May"
            JN_m:   .asciz  "June"
            JL_m:   .asciz  "July"
            AU_m:   .asciz  "August"
            SE_m:   .asciz  "September"
            OC_m:   .asciz  "October"
            NV_m:   .asciz  "November"
            DE_m:   .asciz  "December"

.align      4                                                   // Memory alignment.
.section    ".data"                                             // New data section for an array of suffixes.
       daySuffix:   .word   st_m, nd_m, rd_m, th_m

            st_m:   .asciz  "st"                                // Suffixes for appropriate day numbers. I.e. 1st, 2nd, 3rd, 4th.
            nd_m:   .asciz  "nd"
            rd_m:   .asciz  "rd"
            th_m:   .asciz  "th"

.align      4                                                   // Memory alignment
.section    ".data"                                             // New data section upper bounds on day number.

       dayBounds:   .word   JAd_m, FBd_m, MAd_m, APd_m, MYd_m, JNd_m, JLd_m, AUd_m, SEd_m, OCd_m, NVd_m, DEd_m

            JAd_m:  .asciz  "31"                                // Upper bounds for day numbers, relative to the month.
            FBd_m:  .asciz  "28"
            MAd_m:  .asciz  "31"
            APd_m:  .asciz  "30"
            MYd_m:  .asciz  "31"
            JNd_m:  .asciz  "30"
            JLd_m:  .asciz  "31"
            AUd_m:  .asciz  "31"
            SEd_m:  .asciz  "30"
            OCd_m:  .asciz  "31"
            NVd_m:  .asciz  "30"
            DEd_m:  .asciz  "31"

.section    ".text"                                             

begin_main                                           // Beggining main()

check:          cmp     w10, 4                       // Checking the number of elements in arguments array.
                be      validArguments               // If exactly equal to 4, then proceed ahead.
                nop

                set     argumentsBad, w0             // Or else, set error message in argumentsBad to w0.
                call    printf                       // Printing the error message.
                nop

                call    exit                         // Exiting the program.
                nop

validArguments: set     month, x0                    // Making the month array locally accessible. 
                set     daySuffix, x8                // Making the suffix array locally accessible.
                set     dayBounds, x2                // Making the upper bounds array locally acessible.

monthCheck:     ld      [x1 + 4], w0                 // Taking the first argument for month.
                call    atoi                         // Changing ASCII String to Integer type.
                nop

                mov     w0, x3                      // Moving the new integer month to local register to avoid overwriting.
                sub     x3, 1, x3                   // Subtracting 1 from the month.
                smul    x3, 4, x3                   // Multiplying by 4. Use x3 register to access the month in month array.

                cmp     w0, 0                       // Checking lower bound. If 0 < month, proceed ahead.
                ble     badArgsMonth                // Or else, branch it to the badArgsMonth to print the error message and exit the program.
                nop
                
                cmp     w0, 12                      // Checking upper bound. If month < 13, proceed ahead. (i.e. 0 < month < 13).
                bg      badArgsMonth                // Or else, branch it to the badArgsMonth to print the error message and exit the program.
                nop

dayCheck:       ld      [x1 + 8], w0                // Taking the second argument for day.
                call    atoi                        // Change ASCII String to Integer type.
                nop

                mov     w0, x4                      // Moving the new integer day to local register to avoid overwriting.

                cmp     x4, 0                       // Checking lower bound. If 0 < day, proceed ahead.
                ble     badArgsDay                  // Or else, branch it to the badArgsDay to print the error message and exit the program.
                nop

                ld      [x2 + x3], w0              // Loading the upper bound according to the month.
                call    atoi                       // Changing ASCII String to Integer type.
                nop
                
                cmp     x4, w0                     // Checking upper bound. If day < upper bound + 1,  proceed ahead. 
                                                   // (i.e. 0 < day < upper bound + 1).
                bg      badArgsDay                 // Or else, branch it to the badArgsDay to print the error message and exit the program.
                nop
                
yearCheck:      ld      [x1 + 12], w0              // Taking the third argument for year.
                call    atoi                       // Change ASCII String to Integer type.
                nop
                
                cmp     w0, 0                      // Checking lower bound. If year < -1, proceed ahead.
                bl      badArgsYear                // Or else, branch it to the badArgsYear to print the error message and exit.
                nop
                
                set     9999, w5                   // Setting 9999 to a register to avoid Assembler Overflow.
                
                cmp     w0, w5                     // Checking upper bound. If year < 10000, proceed ahead.
                bg      badArgsYear                // Or else, branch it to the badArgsYear to print the error message and exit the program.
                nop
                
                ba      suffixTest                 // All arguments valid. Proceeding to find appropriate suffix for day.
                nop
                
badArgsMonth:   set     monthBad, w0               // Setting the appropriate error message to output register.
                call    printf                     // Printing the error message.
                nop
                
                call    exit                       // Exit the program.
                nop

badArgsDay:       set     dayBad, w0               // Setting the appropriate error message to output register.
                call    printf                     // Printing the error message.
                nop
                
                call    exit                       // Exit the program.
                nop

badArgsYear:       set     yearBad, w0             // Setting the appropriate error message to output register.
                call    printf                     // Printing the error message.
                nop
                
                call    exit                       // Exit the program.
                nop

suffixTest:     cmp     x4, 3                      // Is the day < 3? If it is not, proceed ahead.
                ble     setSuffixA                 // Or else, branch it to the setSuffixA for more specific tests.
                nop
                
                cmp     x4, 31                     // Is the day = 31? If it is not, proceed ahead.
                be      setSuffST                  // Or else, branch it to the setSuffST to set suffix to "st."
                nop
                
                cmp     x4, 21                     // Does 20 < day < 31? If it is not, proceed ahead.
                bge     setSuffixB                 // Or else, branch it to the setSuffixB for more specific tests.
                nop
                
                ld      [x8 + 12], w3              // Since all tests failed, day must have suffix "th."
                
                ba      printArgs                  // Proceeding to output handling.
                nop

setSuffixA:     cmp     x4, 3                      // Is the day = 3? If it is not, proceed ahead.
                be      setSuffRD                  // Or else, branch it to the setSuffRD to set suffix to "rd."
                nop
                
                cmp     x4, 2                       // Is the day = 2? If it is not, proceed ahead.
                be      setSuffND                   // Or else, branch it to the setSuffND to set suffix to "nd."
                nop
                
                ld      [x8 + 0], w3                // If day < 3, but day != 2 or 3, so days ending in 1. Setting suffix to "st."
                
                ba      printArgs                   // Proceeding to output handling.
                nop
                
setSuffixB:     cmp     x4, 21                      // Is the day = 21? If it is not, proceed ahead.
                be      setSuffST                   // Or else, branch it to the setSuffST to set suffix to "st."
                nop
                
                cmp     x4, 22                      // Is the day = 22? If it is not, proceed ahead.
                be      setSuffND                   // Or else, branch it to the setSuffND to set suffix to "nd."
                nop
                
                cmp     x4, 23                      // Is the day = 23? If it is not, proceed ahead.
                be      setSuffRD                   // Or else, branch it to the setSuffRD to set suffix to "rd."
                nop
                
                ld      [x8 + 12], w3               // Days between 23 and 31, set suffix to "th."
                
                ba      printArgs                   // Proceeding to output handling.
                nop
                
setSuffST:    ld      [x8 + 0], w3                  // Setting suffix to "st."
                
                ba      printArgs                   // Proceeding to output handling.
                nop

setSuffND:    ld      [x8 + 4], w3                  // Setting suffix to "nd."
                    
                ba      printArgs                   // Proceeding to output handling.
                nop
                
setSuffRD:    ld      [x8 + 8], w3                  // Setting suffix to "rd" and proceed ahead to output handling.
                
printArgs:      ld      [x0 + x3], w1               // Loading month name as first argument
                ld      [x1 + 8], w2                // Loading day number as second argument.
                ld      [x1 + 12], w4               // Suffix is already set as the third argument,
                                                               
                
                set     date, w0                    // Setting date as output asciz.
                call    printf                      // Printing output asciz.
                nop
end_main
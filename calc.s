#!/usr/bin/spim -f
main:
        lb $s0, sinc            # Set $s0 to contain the sin character
        lb $s1, cosc            # Set $s1 to contain the cos character
        lb $s2, tanc            # Set $s2 to contain the tan character
        lb $s3, cotc            # Set $s3 to contain the cot character
        lb $s4, secc            # Set $s4 to contain the sec character
        lb $s5, cscc            # Set $s5 to contain the csc character
        lb $s6, quitc           # Set $s6 to contain the quit character
        
char:   li $v0, 12               # set the operation to read_character
        syscall                 # get the operator from the user
        move $t1, $v0
        li $v0, 12
        syscall
        
        beq $t1, $s6, exit      # If the user enters 'q', exit the program
        
        bgt $t7, $zero, skip    # If we have an operand on the stack, read at most one operand
        
        li $v0, 7               # set the operation to read_float
        syscall                 # get the first operand from the user
        
        addi $sp, $sp, -8       # decrement stack pointer
        s.d $f0, 0($sp)         # store the first operand on the stack
        
skip:   beq $t1, $s0, sin       # perform sin
        beq $t1, $s1, cos       # perform cos
        beq $t1, $s2, tan       # perform tan
        beq $t1, $s3, cot       # perform cot
        beq $t1, $s4, sec       # perform sec
        beq $t1, $s5, csc       # perform csc

        lb $s0, plusc           # Set $s0 to contain the plus character
        lb $s1, timesc          # Set $s1 to contain the times character
        lb $s2, divc            # Set $s2 to contain the divide character
        lb $s3, subc            # Set $s3 to contain the subtract character
        lb $s4, expc            # Set $s4 to contain the power character

        li $v0, 7               # set the operation to read_float
        syscall                 # get the next operand from the user
        
        addi $sp, $sp, -8       # decrement stack pointer
        s.d $f0, 0($sp)         # store the second operand on the stack

        beq $t1, $s0, plus      # Perform addition
        beq $t1, $s1, times     # Perform multiplication
        beq $t1, $s2, divd      # Perform division
        beq $t1, $s3, subt      # Perform subtraction
        beq $t1, $s4, exp       # Perform exponentiation

        la $a0, bad             # If an illegal character has been entered, alert the user, then try again
        li $v0, 4
        syscall
        
        addi $sp, $sp, 8        # Increment the stack pointer to ignore the operand read after the illegal character

        j main                  # Try reading a character again

plus:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        add.d $f12, $f4, $f6    # Add the two operands
        
        j end                   # Perform all necessary operations after computing the result

times:  l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        mul.d $f12, $f4, $f6    # Multiply the two operands
        
        j end                   # Perform all necessary operations after computing the result

divd:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        div.d $f12, $f6, $f4    # Divide the two operands

        j end                   # Perform all necessary operations after computing the result

subt:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        sub.d $f12, $f6, $f4    # Subtract the two operands

        j end                   # Perform all necessary operations after computing the result

exp:    l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8
        
        li.d $f12, 0.0          # Set $f12 to zero
        c.eq.d $f4, $f12        # Check if the exponent is 0
        
        li.d $f12, 1.0          # Set $f12 to 1 (it will be the output if $f4=0, otherwise it is necessary for the exponentiation below)
        bc1f cont               # If the exponent is not 0, keep continue the algorithm
        
        j end                   # Perform all necessary operations after computing the result
        
cont:   li.d $f8, 0.0           # Set $f8 to 0
        c.eq.d $f4, $f8
        bc1t end                # Keep going until the exponent hits zero
        
        mul.d $f12, $f12, $f6   # Multiply $f6 by the running product in $f12
        li.d $f8, 1.0           # Set $f8 to 1
        sub.d $f4, $f4, $f8     # Decrement $f4
        
        j cont                  # Continue multiplication

sin:    l.d $f4, 0($sp)         # Get the operand
        addi $sp, $sp, 8

        j end                   # Perform all necessary operations after computing the result
        
cos:    l.d $f4, 0($sp)         # Get the operand
        addi $sp, $sp, 8

        j end                   # Perform all necessary operations after computing the result

tan:    l.d $f4, 0($sp)         # Get the operand
        addi $sp, $sp, 8

        j end                   # Perform all necessary operations after computing the result

cot:    l.d $f4, 0($sp)         # Get the operand
        addi $sp, $sp, 8

        j end                   # Perform all necessary operations after computing the result

sec:    l.d $f4, 0($sp)         # Get the operand
        addi $sp, $sp, 8

        j end                   # Perform all necessary operations after computing the result

csc:    l.d $f4, 0($sp)         # Get the operand
        addi $sp, $sp, 8

        j end                   # Perform all necessary operations after computing the result
        
end:    addi $sp, $sp, -8       
        s.d $f12, 0($sp)        # Push the result onto the stack
        
        li $v0, 3               # Print the result
        syscall

        li $v0, 4               # Print a newline
        la $a0, return
        syscall
        
        li $t7, 1               # Set the flag
        
        j main                  # Continue the read loop

exit:   li $v0, 10              # Quit the program
        syscall

        .data
op:     .space 2                # Allocate 2 bytes for the operator (one character and null)
bad:    .asciiz "Illegal character entered, try again.\n"
return: .asciiz "\n"
plusc:  .asciiz "+"
timesc: .asciiz "*"
divc:   .asciiz "/"
subc:   .asciiz "-"
expc:   .asciiz "^"
sinc:   .asciiz "s"
cosc:   .asciiz "c"
tanc:   .asciiz "t"
cotc:   .asciiz "o"
secc:   .asciiz "e"
cscc:   .asciiz "a"
quitc:  .asciiz "q"

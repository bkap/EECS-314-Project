main:
        lb $s0, plusc           # Set $s0 to contain the plus character
        lb $s1, timesc          # Set $s1 to contain the times character
        lb $s2, divc            # Set $s2 to contain the divide character
        lb $s3, subc            # Set $s3 to contain the subtract character
        lb $s4, expc            # Set $s4 to contain the power character
        lb $s5, rootc           # Set $s5 to contain the root character
        
        li $v0, 7               # set the operation to read_float
        syscall                 # get the first operand from the user
        
        addi $sp, $sp, -8       # decrement stack pointer
        s.d $f0, 0($sp)         # store the first operand on the stack

read:   li $v0, 7               # set the operation to read_float
        syscall                 # get the next operand from the user
        
        addi $sp, $sp, -8       # decrement stack pointer
        s.d $f0, 0($sp)         # store the second operand on the stack
                
char:   li $v0, 8               # set the operation to read_string
        la $a0, op              # tell the system where to put the string
        li $a1, 2               # tell the system to read two bytes for the string

        syscall                 # get the operator from the user

        la $t0, op
        lb $t1, 0($t0)          # load the operator for comparison

        beq $t1, $s0, plus      # Perform addition
        beq $t1, $s1, times     # Perform multiplication
        beq $t1, $s2, divd      # Perform division
        beq $t1, $s3, subt      # Perform subtraction
        beq $t1, $s4, exp       # Perform exponentiation
        beq $t1, $s5, root      # Perform root

        la $a0, bad             # If an illegal character has been entered, alert the user, then try again
        li $v0, 4
        syscall

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail

        j char                  # Try reading a character again

plus:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        add.d $f12, $f4, $f6    # Add the two operands

        addi $sp, $sp, -8
        s.d $f12, 0($sp)        # Push the result onto the stack
        
        li $v0, 3               # Print the result
        syscall

        li $v0, 4               # Print a newline
        la $a0, return
        syscall

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail
        
        j read                  # Continue the read loop

times:  l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        mul.d $f12, $f4, $f6    # Multiply the two operands

        addi $sp, $sp, -8
        s.d $f12, 0($sp)        # Push the result onto the stack
        
        li $v0, 3               # Print the result
        syscall

        li $v0, 4               # Print a newline
        la $a0, return
        syscall

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail
        
        j read                  # Continue the read loop

divd:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        div.d $f12, $f6, $f4    # Divide the two operands

        addi $sp, $sp, -8
        s.d $f12, 0($sp)        # Push the result onto the stack
        
        li $v0, 3               # Print the result
        syscall

        li $v0, 4               # Print a newline
        la $a0, return
        syscall

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail

        j read                  # Continue the read loop

subt:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        sub.d $f12, $f6, $f4    # Subtract the two operands

        addi $sp, $sp, -8
        s.d $f12, 0($sp)        # Push the result onto the stack
        
        li $v0, 3               # Print the result
        syscall

        li $v0, 4               # Print a newline
        la $a0, return
        syscall

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail

        j read                  # Continue the read loop

exp:    l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail

        j read                  # Continue the read loop

root:   l.d $f4, 0($sp)         # Get the second operand
        addi $sp, $sp, 8
        l.d $f6, 0($sp)         # Get the first operand
        addi $sp, $sp, 8

        li $v0, 7               # Flush the input
        syscall                 # Something appears to remain in the input, causing the next read to fail

        j read                  # Continue the read loop

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
rootc:  .asciiz "~"
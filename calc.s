#!/usr/bin/spim -f
main:
        lb $s0, sinc            # Set $s0 to contain the sin character
        lb $s1, cosc            # Set $s1 to contain the cos character
        lb $s2, tanc            # Set $s2 to contain the tan character
        lb $s3, cotc            # Set $s3 to contain the cot character
        lb $s4, secc            # Set $s4 to contain the sec character
        lb $s5, cscc            # Set $s5 to contain the csc character
        lb $s6, quitc           # Set $s6 to contain the quit character
        
char:   li $v0, 12              # set the operation to read_character
        syscall                 # get the operator from the user
        move $t1, $v0
        move $s7, $t1
        li $v0, 12
        syscall                 # clear the newline from the input
        
        beq $t1, $s6, exit      # If the user enters 'q', exit the program
        
        bgt $t7, $zero, skip    # If we have an operand on the stack, read at most one operand
        
        li $v0, 8               # set the operation to read_float
        add $a0, $sp, $zero
        li $a1, 8
        
        syscall                 # get the first operand from the user
        jal atof
        addi $sp, $sp, -8       # decrement stack pointer
        s.d $f30, 0($sp)         # store the first operand on the stack
        move $t1, $s7
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
        li $v0, 8
        addi $sp, $sp, -8
        add $a0, $sp, $zero
        li $a1, 8
        syscall                 # get the next operand from the user
        jal atof
        
        s.d $f30, 0($sp)         # store the second operand on the stack
        move $t1, $s7
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
        c.eq.d $f6, $f12        # Check if the base is 0
        bc1f econt0             # Continue if the base is not 0
        c.eq.d $f4, $f12        # Check if the exponent is also 0
        bc1f end                # If not, return 0

        la $a0, bad             # 0^0 is undefined.  Therefore, we
        li $v0, 4               # should throw an error if the user
        syscall                 # asked us to compute it.
        j main

econt0: c.eq.d $f4, $f12        # Check if the exponent is 0
        
        li.d $f12, 1.0          # Set $f12 to 1 (it will be the output if $f4=0, otherwise it is necessary for the exponentiation below)
        bc1f econt1             # If the exponent is not 0, keep continue the algorithm
        
        j end                   # Perform all necessary operations after computing the result
        
econt1: li.d $f8, 0.0           # Set $f8 to 0
        c.eq.d $f4, $f8
        bc1t end                # Keep going until the exponent hits zero
        
        c.lt.d $f4, $f8         # Check if there is a fractional part to the exponent
        bc1t frac               # If so, jump to the computation for the fractional part
        
        mul.d $f12, $f12, $f6   # Multiply $f6 by the running product in $f12
        li.d $f8, 1.0           # Set $f8 to 1
        sub.d $f4, $f4, $f8     # Decrement $f4
        
        j cont                  # Continue multiplication
        
### fractional exponent ###
        # Compute the fractional part of the exponent using the Taylor
        # expansion for x^b about 1, then multiply by the integer part
        # of the exponent
        #f0: holds the previous accumulated total
        #f2: current accumulated total
        #f4: the exponent
        #f6: the base of the exponent
        #f8: a constant, 0 or 1 as needed
        #f10: counter for factorial
        #f12: the integer portion of the exponent and return value
        #f14: the current coefficient
        #f16: the variable term
        #f18: temporary
frac:   li.d $f8, 1.0           # set $f8 to 1
        c.le.d $f6, $f8
        li.d $f8, 0.0           # set $f8 to 0

        bc1t fcont0             # If the base is greater than 1, take
        div.d $f6, $f8, $f6     # the reciprocal and negate the exponent.
        li.d $f8, 0.0           
        sub.d $f4, $f8, $f4

fcont0: c.le.d $f6, $f8
        bc1f fcont1

        la $a0, bad             # If the base is negative or zero, throw
        li $v0, 4               # an error and let the user enter new
        syscall                 # numbers
        j main

fcont1: li.d $f8, 1.0
        li.d $f2, 1.0           # Set accumulated total to 1
        sub.d $f6, $f6, $f8     # $f6 is now the base's distance from 1
        li.d $f10, 1.0          # Initialize the factorial counter
        li.d $f14, 1.0          # Initialize the coefficient
        li.d $f16, 1.0          # Initialize variable term

floop:  mov.d $f0, $f2          # Save the current total
        div.d $f18, $f4, $f10   # multiply coefficient by
        mul.d $f14, $f14, $f18  # exponent/factorial counter
        mul.d $f16, $f16, $f6   # add 1 to exponent of variable term
        mul.d $f18, $f14, $f16  # add product to accumulated total
        add.d $f2, $f2, $f18
        sub.d $f4, $f4, $f8     # decrement exponent
        add.d $f10, $f10, $f8   # increment factorial counter

        c.eq.d $f0, $f2         # repeat until the current term is below
        bc1f floop              # the precision of the total
        mul.d $f12, $f2, $f12   # multiply integer and fractional exponents
        j end

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
#### infix parser #######
    #op table:
    #+ = 0
    #- = 1
    #* = 2
    #/ = 3
    #^ = 4
    #sin = 5
    #cos = 6
    #tan = 7
    #( = 8

    #reg allocation:
    #s0 = bottom of op stack
    #s1 = top of op stack. s0 = s1 means stack is empty
    #s2 = bottom of num stack
    #s3 = top of num stack
    #s4 = last action
        #0 = paren
        #1 = op
        #2 = number
        #3 = eval
    #will keep a0 as current string location
    #
infix:
    addi $sp, $sp, -8
    add $s0, $sp, $zero #s0 = op table. Use bytes for ops. Max 8 ops should be
                    #enough
    
    add $s1, $s0, $zero #s1 will be the top of the stack
    addi $sp, $sp, -8

    add $s2, $sp, $zero #s2 will be the number stack, each number takes up 2
                        #words. Will allocate for 8 numbers = 64 bytes
    addi, $sp, $sp, -64
    add $s3, $s2, $zero #s3 will be the top of the number stack
    #s4 = prev action. 
    add $s4, $zero, $zero

######STRCMP AND STRCASECMP#####
strcmp:
        #a0 = loc of string 1
        #a1 = loc of string 2
        #v0 = 0 if they're the same, nonzero if they're different
        add $t2, $a0, $zero
        add $t3, $t1, $zero
strcmp2:
        lbu $t0, 0($t2)
        lbu $t1, 0($t3)
        beq $t0, $zero, endcmp
        beq $t1, $zero, endcmp
        bne $t0, $t1, endcmp
        addi $t2, $t2, 1
        addi $t3, $t3, 1
        j strcmp2
endcmp:
        add $v0, $t0, $t1
        add $v1, $t2, $zero #set v1 = end pointer
        jal $ra

strcasecmp:
    #convert $a0 and $a1 to upper case and return strcmp
        addi $t0, $zero, 0x61 #'a'
        addi $t1, $zero, 0x7a #'z'
        addi $t5, $zero, 0x20 # space for terminating
        add $t2, $a0, $zero
        add $t3, $a1, $zero
cvrt0:
        lbu $t4, 0($t2)
        beq $t4, $zero, cvrt1
        beq $t4, $t5, strcmp
        blt $t4, $t0, cvrt02
        bgt $t4, $t1, cvrt02
        addi $t4, $t4, -32 #difference between upper and lower case
        sw $t4, 0($t2)
cvrt02:
        addi $t2, $t2, 1
        j cvrt0
cvrt1:
        lbu $t4, 0($t3)
        beq $t4, $zero, strcmp #should always get called, as long as you have
                                #null terminated strings
        beq $t4, $t5, strcmp
        blt $t4, $t0, cvrt12
        bgt $t4, $t1, cvrt12
        addi $t4, $t4, -32
        sw $t4, 0($t3)
cvrt12:
        addi $t3, $t3, 1
        j cvrt1

###### END STRCMP ####

##### atof ######
atof:
        #stuff is in the same position as the sys call.
        #a0 is the location of the string, a1 is the length
        #f30 is the return value.

        addi $a3, $zero, 0x20 #terminate on space. Yes I know this isn't a
                                #temp, but I'm using all of them
        add $t0, $a0, $zero #p in the sample code
        addi $t1, $zero, 32 #keep going if it's less than this
        lbu $t2, 0($t0)

    #while isspace p++
isspace: bgt $t2, $t1, endspace
         beq $t2, $zero, retz #if it ends in a null a null, return 0
         addi $t0, $t0, 1
         lbu $t2, 0($t0)
         j isspace
endspace:
        add $t4, $zero, $zero #t4 = negative
        addi $t5, $zero, 0x2D #check for asii minus
        bne $t2, $t5, SKIPNEG
        addi $t4, $zero, 1
        addi $t0, $t0, 1 #p++
        j cont1
SKIPNEG: addi $t5, $zero, 0x2B #check for ascii plus
         bne $t2, $t5, cont1
         addi $t0, $t0, 1 #p++
cont1: 
        #f30 = num
        #t6 = flag
        #t7 = exp
        #t8 = num_digits
        #t9 = num_dec

        add $t9, $zero, $zero
        add $t8, $zero, $zero
        add $t7, $zero, $zero
        add $t6, $zero, $zero


        #increment stack pointer so I can use it
        #also, set some values to 0
    
        addi $sp, $sp, -4
        #put 10 in $f14
        addi $t5, $zero, 10
        sw $t5, 0($sp)
        lwc1 $f14, 0($sp)
        cvt.d.w $f14, $f14
        #clear $f30
        sw $zero, 0($sp)
        lwc1 $f30, 0($sp)
        cvt.d.w $f30, $f30
isdigit:
        lbu $t2, 0($t0)
        #make sure we didn't use all chrs
        beq $t2, $zero, enddig
        beq $t2, $a3, enddig
        #check lt '0'
        addi $t5, $zero, 0x30
        blt $t2, $t5, enddig
        addi $t5, $t5, 9 #check if gt 9
        bgt $t2, $t5, enddig

        #now we know it's a digit
        
        #n = n * 10
        mul.d $f30, $f30, $f14
        
        #x = (p-'0')
        addi $t2, $t2, -48
        sw $t2, 0($sp)
        lwc1 $f16, 0($sp)
        cvt.d.w $f16, $f16

        #n += p
        add.d $f30, $f30, $f16

        #p++
        addi $t0, $t0, 1
        #num_digits ++
        addi $t8, $t8, 1
        add $t9, $t9, $t6 #t6 = 0 during int part
                           #1 during exp part
        sub $t7, $zero, $t9
        j isdigit

enddig: 
        beq $t2, $zero, enddec
        beq $t2, $a3, enddec
        #use t6 as a flag to check if I've done decimals
        bne $t6, $zero, enddec
        #check to see if we've hit a '.'
        addi $t5, $zero, 0x2e
        addi $t6, $zero, 1
        bne $t5, $t2, enddec
        addi $t0, $t0, 1
        j isdigit
enddec:
        #if num_digits == 0, error
        beq $t8, $zero, error
        #if negative, number = -number
        beq $t4, $zero, testexp
        neg.d $f30, $f30

        #check for E
testexp:
        beq $t2, $zero, endexp
        beq $t2, $a3, endexp
        addi $t5, $zero, 0x45 #E
        beq $t5, $t2, fltexp
        addi $t5, $zero, 0x65 #e
        beq $t5, $t2, fltexp
        j endexp

fltexp:
        add $t4, $zero, $zero
        addi $t0, $t0, 1
        lbu $t2, 0($t0)
        addi $t5, $zero, 0x2D #minus
        beq $t2, $t5, cseneg
        addi $t5, $zero, 0x2B #plus
        beq $t2, $t5, csepos
        j cntexp
cseneg:
        addi $t4, $zero, 1
        syscall
csepos: addi $t0, $t0, 1
cntexp:
    #now using t6 for n
    add $t6, $zero, $zero
isdig2: 
        #exponent stored in $t7
        lbu $t2, 0($t0)
        #make sure we didn't use all chrs
        beq $t2, $zero, enddig2
        beq $t2, $a3, enddig2
        #check lt '0'
        addi $t5, $zero, 0x30
        blt $t2, $t5, enddig2
        addi $t5, $t5, 9 #check if gt 9
        bgt $t2, $t5, enddig2

        #now we know it's a digit
        
        #n = n * 10
        addi $t5, $zero, 10
        mult $t6, $t5
        mflo $t6
        
        #x = (p*-'0')
        addi $t2, $t2, -48
        #n += x
        add $t6, $t6, $t2

        #p++
        addi $t0, $t0, 1
        j isdig2
enddig2:
        beq $t4, $zero, addexp
        sub $t6, $zero, $t6
addexp: add $t7, $t7, $t6


endexp:
        #check to see if exponent in range
        addi $t5, $zero, -1022 #dbl min exp
        blt $t7, $t5, error #ERANGE
        addi $t5, $zero, 1023 #dbl max exp
        bgt $t7, $t5, error
        
        #scale result
        #f14 already = 10, so I'm using that as p10
        addi $t6, $t7, 0
        bge $t6, $zero, scale
        negu $t6, $t6
scale:  beq $t6, $zero, endatof
        andi $t4, $t6, 1
        beq $t4, $zero, cntscl
        blt $t7, $zero, divscl
        #exp >= 0
        mul.d $f30, $f30, $f14
        j cntscl
divscl: div.d $f30, $f30, $f14
cntscl:
        sra $t6, $t6, 1
        mul.d $f14, $f14, $f14
        j scale
        error: #need to take care of error handeling later
retz:
        sw $zero, 0($sp)
        lwc1 $f30, 0($sp)
        cvt.d.w $f30, $f30
endatof:
        addi $sp, $sp, 4 #remove that stack location I used
        add $v1, $t0, $zero #set v1 to the end pointer
        jr $ra

##### END ATOF ######


exit:   li $v0, 10              # Quit the program
        syscall

        .data
op:     .space 5                # Allocate 2 bytes for the operator (one character and null)
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

#!/usr/bin/spim -f
main:
        li $v0, 8               # set the operation to read_string
        li $a1, 128
        la $a0, inp
        syscall                 # get the input
        move $s7, $a0
        
        # Create a number stack
        add $s2, $sp, $zero     # $s2 is top of the number stack
        addi $sp, $sp, -128     # Space for 16 doubles
        add $s3, $s2, $zero     # $s3 is bottom of number stack
        
rpn:    li $t0, 21
        li $t1, 0
        li $t3, 32              # ASCII space = 32
        li $t5, 10
        la $a1, op
        
rpnl:   add $t2, $t1, $s7
        add $t4, $t1, $a1
        lb $t2, 0($t2)          # $t2 contains the current character
        beq $t0, $t1, rpnpa
        ble $t2, $t3, rpnpa
        sb $t2, 0($t4)          # Store the current character in a string
        addi $t1, $t1, 1
        j rpnl
        
rpnpa:  beq $t1, $zero, res    # If there is no more input, print the result
        li $t2, 0
        add $t3, $t1, $a1
        sb $t2, 0($t3)         # Store the null character
        
        li $t2, 1
        add $t3, $t1, $t2
        add $s7, $s7, $t3
        
        la $a0, quop            # Quit
        jal strcmp
        beq $v0, 0, exit
        
        la $a0, plop            # Addition
        jal strcmp
        beq $v0, 0, plus
        
        la $a0, miop            # Subtraction
        jal strcmp
        beq $v0, 0, subt
        
        la $a0, tiop            # Multiplication
        jal strcmp
        beq $v0, 0, times
        
        la $a0, diop            # Division
        jal strcmp
        beq $v0, 0, divd
        
        la $a0, exop            # Exponentiation
        jal strcmp
        beq $v0, 0, exp
        
        la $a0, lgop            # Log_2
        jal strcmp
        beq $v0, 0, log
        
        la $a0, siop            # Sine
        jal strcmp
        beq $v0, 0, sin
        
        la $a0, coop            # Cosine
        jal strcmp
        beq $v0, 0, cos
        
        la $a0, taop            # Tangent
        jal strcmp
        beq $v0, 0, tan
        
        la $a0, csop            # Cosecant
        jal strcmp
        beq $v0, 0, csc
        
        la $a0, seop            # Secant
        jal strcmp
        beq $v0, 0, sec
        
        la $a0, ctop            # Cotangent
        jal strcmp
        beq $v0, 0, cot
        
        la $a0, asiop            # ArcSine
        jal strcmp
        beq $v0, 0, asin
        
        la $a0, acoop            # ArcCosine
        jal strcmp
        beq $v0, 0, acos
        
        la $a0, ataop            # ArcTangent
        jal strcmp
        beq $v0, 0, atan
        
        la $a0, acsop            # ArcCosecant
        jal strcmp
        beq $v0, 0, acsc
        
        la $a0, aseop            # ArcSecant
        jal strcmp
        beq $v0, 0, asec
        
        la $a0, actop            # ArcCotangent
        jal strcmp
        beq $v0, 0, acot
        
        move $a0, $a1
        jal atof
        beq $s3, $sp, full
        addi $s3, $s3, -8
        s.d $f30, 0($s3)
        
        j rpn

full:   la $a0, fulls
        li $v0, 4
        syscall
        
        j main
        
malf:   la $a0, malfs
        li $v0, 4
        syscall
        
        j main

plus:   beq $s3, $s2, malf      # Malformed input
        l.d $f4, 0($s3)         # Get the second operand
        addi $s3, $s3, 8
        beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the first operand
        addi $s3, $s3, 8

        add.d $f12, $f4, $f6    # Add the two operands
        
        j end                   # Perform all necessary operations after computing the result

times:  beq $s3, $s2, malf      # Malformed input
        l.d $f4, 0($s3)         # Get the second operand
        addi $s3, $s3, 8
        beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the first operand
        addi $s3, $s3, 8

        mul.d $f12, $f4, $f6    # Multiply the two operands
        
        j end                   # Perform all necessary operations after computing the result

divd:   beq $s3, $s2, malf      # Malformed input
        l.d $f4, 0($s3)         # Get the second operand
        addi $s3, $s3, 8
        beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the first operand
        addi $s3, $s3, 8

        div.d $f12, $f6, $f4    # Divide the two operands

        j end                   # Perform all necessary operations after computing the result

subt:   beq $s3, $s2, malf      # Malformed input
        l.d $f4, 0($s3)         # Get the second operand
        addi $s3, $s3, 8
        beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the first operand
        addi $s3, $s3, 8
        
        sub.d $f12, $f6, $f4    # Subtract the two operands

        j end                   # Perform all necessary operations after computing the result

exp:    beq $s3, $s2, malf      # Malformed input
        l.d $f4, 0($s3)         # Get the second operand
        addi $s3, $s3, 8
        beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the first operand
        addi $s3, $s3, 8
        
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
        
        j econt1                # Continue multiplication
        
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
        li.d $f8, 1.0           # set $f8 to 1
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
        
log:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        mov.d $f12, $f6         # Make log do nothing right now
        j end                   # Perform all necessary operations after computing the result

sin:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        j end                   # Perform all necessary operations after computing the result
        
cos:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        mov.d $f12, $f18
        j end                   # Perform all necessary operations after computing the result

tan:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f12, $f18
        j end                   # Perform all necessary operations after computing the result

cot:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f18, $f12
        j end                   # Perform all necessary operations after computing the result

sec:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f8, $f18
        j end                   # Perform all necessary operations after computing the result

csc:    beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f8, $f12
        j end                   # Perform all necessary operations after computing the result
        
asin:   beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        j end                   # Perform all necessary operations after computing the result
        
acos:   beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        mov.d $f12, $f18
        j end                   # Perform all necessary operations after computing the result

atan:   beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f12, $f18
        j end                   # Perform all necessary operations after computing the result

acot:   beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f18, $f12
        j end                   # Perform all necessary operations after computing the result

asec:   beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f8, $f18
        j end                   # Perform all necessary operations after computing the result

acsc:   beq $s3, $s2, malf      # Malformed input
        l.d $f6, 0($s3)         # Get the operand
        addi $s3, $s3, 8
        jal trig
        div.d $f12, $f8, $f12
        j end                   # Perform all necessary operations after computing the result
        
### trig internals ###
        # Compute sin(x) using a Taylor expansion
        # Returns sin(x) in $f12, cos(x) in $f18, and 1 in $f8
        #f0: holds the previous accumulated total
        #f2: current accumulated total
        #f4: not used
        #f6: the argument
        #f8: used to store constants
        #f10: counter for factorial
        #f12: the return value
        #f14: the current coefficient
        #f16: the variable term
        #f18: temporary
trig:   abs.d   $f18, $f6       # Ensure that the argument can be
        li.d    $f8, 1.3493037704e10 # represented as a fixed-point word.
        c.le.d  $f18, $f8
        bc1t    tcont0

        la      $a0, bad        # If it is too large, throw an error
        li      $v0, 4          # message and let the user enter new
        syscall                 # numbers
        j main

tcont0: li.d $f8, 6.28318530717953072
        div.d $f18, $f6, $f8    # Convert the argument to a value
        round.w.d $f18, $f18    # between -pi and pi
        cvt.d.w $f18, $f18
        mul.d $f18, $f18, $f8
        sub.d $f6, $f6, $f18
        
        li.d $f2, 0.0           # Set accumulated total to 0
        li.d $f8, -1.0          # set $f8 to 1
        li.d $f10, 1.0          # Initialize the factorial counter
        li.d $f14, 1.0          # Initialize the coefficient
        li.d $f16, 1.0          # Initialize variable term

tloop:  mov.d $f0, $f2          # Save the current total
        div.d $f14, $f14, $f10  # divide coefficient by factorial counter
        sub.d $f10, $f10, $f8   # increment factorial counter
        mul.d $f16, $f16, $f6   # add 1 to exponent of variable term
        mul.d $f18, $f14, $f16  # add product to accumulated total
        add.d $f2, $f2, $f18
        mul.d $f14, $f14, $f8   # negate the coefficient
        div.d $f14, $f14, $f10  # divide coefficient by factorial counter
        sub.d $f10, $f10, $f8   # increment factorial counter
        mul.d $f16, $f16, $f6   # add to exponent again

        c.eq.d $f0, $f2         # repeat until the current term is below
        bc1f tloop              # the precision of the total
        mov.d $f12, $f2         # move the total to the return value

	    li.d $f8, 1.0
        mul.d $f18, $f12, $f12  # Compute the cosine from the sine.
        sub.d $f18, $f8, $f18   # cos(x)=+/-sqrt(1-sin(x)^2)
        sqrt.d $f18, $f18       # It's negative iff |x|>pi/2
        abs.d $f6, $f6
        li.d $f8, 1.57079632679489662 # This is slightly greater than pi/2
        c.lt.d $f6, $f8
        bc1f tneg
        li.d $f8, 1.0
        jr $ra
tneg:   li.d $f8, 0.0
        sub.d $f18, $f8, $f18
        li.d $f8, 1.0
        jr $ra

end:    addi $s3, $s3, -8       
        s.d $f12, 0($s3)        # Push the result onto the stack
        
        j rpn                  # Continue the read loop
        
res:    l.d $f12, 0($s3)         # Get the result
        addi $s3, $s3, 8
        li $v0, 3
        syscall
        la $a0, return
        li $v0, 4
        syscall
        j main


######STRCMP AND STRCASECMP#####
strcmp:
        #a0 = loc of string 1
        #a1 = loc of string 2
        #v0 = 0 if they're the same, nonzero if they're different
        add $t2, $a0, $zero
        add $t3, $a1, $zero
        addi $t4, $zero, 32 #ignore leading whitespace

#ignore leading whitespace
        lbu $t0, 0($t2)
        lbu $t1, 0($t3)

rmspc:  bgt $t0, $t4, rmspc2
        lbu $t0, 0($t2)
        j rmspc

rmspc2: bgt $t1, $t4, strcmp2
        lbu $t1, 0($t3)
        j rmspc2

strcmp2:
        lbu $t0, 0($t2)
        lbu $t1, 0($t3)
        beq $t0, $zero, endcmp
        beq $t1, $zero, endcmp
        ble $t0, $t4, endcmp
        ble $t1, $t4, endcmp
        bne $t0, $t1, endcmp
        addi $t2, $t2, 1
        addi $t3, $t3, 1
        j strcmp2
endcmp:
        slt $v0, $t4, $t0
        slt $t1, $t4, $t1
        add $v0, $v0, $t1
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
        #a0 is the location of the string,
        #f30 is the return value.

        add $t0, $a0, $zero #p in the sample code
        addi $t1, $zero, 32 #keep going if it's less than this
        lbu $t2, 0($t0)

    #while isspace p++
isspace:
        bgt $t2, $t1, endspace
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
SKIPNEG: 
        addi $t5, $zero, 0x2B #check for ascii plus
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
    
        addi $sp, $sp, -8
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
        ble $t2, $t1, enddec
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
        ble $t2, $t1, endexp
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
        addi $sp, $sp, 8 #remove that stack location I used
        add $v1, $t0, $zero #set v1 to the end pointer
        jr $ra

##### END ATOF ######


exit:   li $v0, 10              # Quit the program
        syscall

        .data
op:     .space 21                # Allocate 21 bytes for a number (20 digits, 1 null)
bad:    .asciiz "Illegal character entered, try again.\n"
fulls:  .asciiz "The number stack is full. The calculator will now be reset.\n"
malfs:  .asciiz "You have entered too few operands to complete the requested operations. The calculator will now be reset\n"
debug:  .asciiz "debug statement\n"
return: .asciiz "\n"
plop:   .asciiz "+"
miop:   .asciiz "-"
tiop:   .asciiz "*"
diop:   .asciiz "/"
exop:   .asciiz "^"
siop:   .asciiz "sin"
coop:   .asciiz "cos"
taop:   .asciiz "tan"
csop:   .asciiz "csc"
seop:   .asciiz "sec"
ctop:   .asciiz "cot"
quop:   .asciiz "quit"
asiop:  .asciiz "asin"
acoop:  .asciiz "acos"
ataop:  .asciiz "atan"
acsop:  .asciiz "acos"
aseop:  .asciiz "asec"
actop:  .asciiz "acot"
lgop:   .asciiz "log"
inp:    .space 501

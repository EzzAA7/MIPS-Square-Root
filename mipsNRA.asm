# Title: Filename:	Non-Restoring implementation
# Author:Ezz Abu Asab & Adham Saheb	Date:
# Description:
# Input:8 bit integer number (1-255)
# Output:square root of number
################# Data segment #####################
.data
A: .word 0
Q: .word 11
B: .word  5
N: .word 8
AQ: .word 0
two: .float 2
PromptNum: 	.asciiz "Please enter a number"
StringNum: 	.asciiz "Number: "
StringQ: 	.asciiz "Quotient: "
StringRem: 	.asciiz "Remainder: "
StringRoot: 	.asciiz "The Square Root Using NonRestoring Algorithm: "
StringWhile:    .asciiz "############################################"
################# Code segment #####################
.text
.globl main

main: # main program entry
	
	################################### Printing and Reading number #############################################
	la $a0,PromptNum
	jal printString
	
	#new line
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall


	li $v0, 5 # Read integer
	syscall # $v0 = value read
	move $s1,$v0
	
	#new line
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
        
        la $a0, StringNum  
	jal printString

	move $a0, $s1 # $a0 = value to print
	li $v0, 1 # Print integer
	syscall
	
	#new line
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
        ###################################################################################################################################
        
        # We are gonna designate $s2 for Number, $t4 for Temp and $t5 for Sqrt
	#sqrt = number /2 we do this using nonRestoringAlgorithm passing parameter Q=number , B=2
	# so parameter $a0= Q= number &&&& $a1= 2
	
	move $a0,$s1 # $parameter $a0 now has the value of Number
	li $a1,2
	jal nonRestoringAlgo
	
	#procedure returns quotient of division in $t2 we need to move to different register in order to save it
	move $t5,$t2	#sqrt = number/2 done using nonRestoringAlgo procedure
	move $s4,$s1
	li $t4,0	# temp=0
	
	#while loop
	while:	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        	addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        	syscall
        
        	la $a0, StringWhile  
		jal printString
		
		beq $t4,$t5,printRes	#while (sqrt != temp)
		move $t4, $t5		#temp = sqrt
		
		#	sqrt = ( number/temp + temp) / 2
		#so first we need to do division nonRestoringAlgo then add temp then again do division by 2 using nonRestoringAlgo
		
		# number/temp
		move $a0,$s4 # $parameter $a0 now has the value of Number
		move $a1,$t4 # $parameter $a0 now has the value of Temp
		jal nonRestoringAlgo
	
		#procedure returns quotient of division in $t2 we need to move to different register in order to save it
		move $t6,$t2		#sqrt = number/2 done using nonRestoringAlgo procedure
		add $t6,$t6,$t4		#result of div is added to temp
		 
		#then / 2 
		move $a0,$t6 # $parameter $a0 now has the value of ( number/temp + temp)
		li $a1,2
		jal nonRestoringAlgo
		#procedure returns quotient of division in $t2 we need to move to Sqrt register in order to save it
		
	#$ t2 has value of new sqrt and $t5 has value of old sqrt 
	# we can compare to check if we reached a repeating value
	#######beq $t5,$t2 printRes######################
		move $t5,$t2	#$t5 is sqrt so now sqrt =  number/temp + temp) / 2 done using nonRestoringAlgo procedure
		add $s5,$s5,$t1
		j while
		#bne $s4,$t4,while
		#j printRes
		
	
	#incase loop is done (sqrt != temp anymore) then we have the root
	printRes:	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
			addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
			syscall
			
			la $a0, StringRoot
			jal printString # Print string
			
			li $t0,0
			li $t1,2
			li $t2,1
	loop:	beq $t0,$t1,printFloat
			mtc1 $s4,$f2		# from $s5 to $f2 (value of Number)
			cvt.s.w $f2,$f2		# the value in f2 is integer so we convert it to single precision float
			mtc1 $t4,$f4		# from $t4 to $f2 (value of Temp)
			beq $t1,$t2,next	
			cvt.s.w $f4,$f4		# the value in f2 is integer so we convert it to single precision float
		next:	div.s $f0,$f2,$f4	# divide f2 (has multiplication result) by f4 (Number/Temp)
			add.s $f0,$f0,$f4	# add Temp (Number/Temp)+ Temp
			la $t7,two
			l.s $f6,($t7)		# f1 has value of scaler
			div.s $f12,$f0,$f6	# divide f12 (has multiplication result) by 10
			subiu $t1,$t1,1		# decrease counter
			mfc1 $t4,$f12		# reload temp with new value
			j loop

	printFloat:	li $v0, 2 # Print float
			syscall
			
			addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
			addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
			syscall
			b main		   
	
################################### the nonRestoringAlgo procedure it takes $a0 & $a1 as parameters ##################################
nonRestoringAlgo:	lw $s0, A
			move $s1, $a0
			move $s2, $a1
			lw $s3, N
			lw $t0, AQ

			# add A part of AQ with B
			add $t0,$t0,$s0
			sll $t0,$t0,8
			addu $t0,$t0,$s1

			sll $t0,$t0,1
	
	start:	li $t7,0x1FF00
		and $t1,$t0,$t7 #this get A byte in $t1 by masking the bits we dont want with 0 (and 0)
		srl $t1,$t1,8
		li $t7,0x10000
		and $t3,$t0,$t7	#to check 17th bit
		blez $t3, zeroInFirstComp #if A is not less than 0 branch to negativeInFirstComp
		
		add $t1,$t1,$s2 # A= A+B
		b cond

	zeroInFirstComp:
		# subtract A part of AQ with B
		sub $t1,$t1,$s2 # A= A-B
		
		#we need to check the msb in A byte of AQ after subtraction
	cond: 	and $t2,$t0,0x00FF #this get Q byte in $t2 by masking the bits we dont want with 0 (and 0)
		and $t3,$t1,0x100
		blez  $t3, bitEqualZero #if A is not less than 0 (the bit is 0)branch to bitEqualZero
		
		#it reaches here if A<0 (the bit is 1)
		subiu $s3,$s3,1	#n=n-1
		bne $s3, $zero, init
		b reachedZero


	bitEqualZero:		xori $t2,$t2,1		
				subiu $s3,$s3,1
				bne $s3, $zero, init
				b reachedZero
			
	init:	xor $t0,$t0,$t0 #reset AQ

		add $t0,$t0,$t1 #add the new A
		sll $t0,$t0,8	#shift by 4
		addu $t0,$t0,$t2 #add the new Q
		
		sll $t0,$t0,1
		and $t2,$t0,0x00FF #this get Q byte in $t2 by masking the bits we dont want with 0 (and 0)
		li $t7,0x01FFFF
		and $t0,$t0,$t7 #this maskx the bits we dont want with 0 (and 0)
		j start	
		
	reachedZero:	and $t1,$t1,0x1FF #this maskx the bits we dont want with 0 (and 0)
			and $t3,$t1,0x100
			blez  $t3, print #if A is not less than 0 (the bit is 0)branch to positiveInSecondComp
		
		#it reaches here if A<0 (the bit is 1)
		
		add $t1,$t1,$s2 # A= A+B
		and $t1,$t1,0x1FF #this maskx the bits we dont want with 0 (and 0)
		############bne $s3, $zero, init
		b print
			
	print:	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
		addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
		syscall
	
		la $a0, StringQ 
		li $v0, 4 # Print string
		syscall

		move $a0, $t2 # $a0 = value to print ( Quotient)
		li $v0, 1 # Print integer
		syscall
		
		addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
		addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
		syscall
			
		la $a0, StringRem
		li $v0, 4 # Print string
		syscall
			
		move $a0, $t1 # $a0 = value to print (Remainder)
		li $v0, 1 # Print integer
		syscall
		
		addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
		addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
		syscall
		jr $ra
###################################################################################################

printString:		li $v0, 4 # Print string
			syscall
			jr $ra
					
exit:	# Exit program
	li $v0, 10 
	syscall

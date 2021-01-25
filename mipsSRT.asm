# Title: Filename:	SRT implementation
# Author:Ezz Abu Asab & Adham Saheb	Date:
# Description:
# Input:Number between 0 and 1
# Output:square root of number
################# Data segment #####################
.data
Counter: .word 0
N: .word 8
Half: .float 0.5
MinusHalf:	.float -0.5
PromptNum: 	.asciiz "Please enter a number"
StringNum: 	.asciiz "Number: "
StringRoot: 	.asciiz "The Square Root Using SRT Algorithm: "
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

	li $v0, 6 # Read float
	syscall # $f0 = value read
	
	#new line
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
        
        la $a0, StringNum  
	jal printString
	
	mfc1 $t6,$f0
	mtc1 $t6,$f12
	li $v0, 2 # Print float
	syscall
	
	#new line
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
        ###################################################################################################################################
	
	move $a0,$s1 # $parameter $a0 now has the value of Number
	jal SRT

	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
       	addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
       	syscall

	la $a0, StringRoot 
	jal printString
	j exit
	
	printRes:	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
			addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
			syscall
			
			la $a0, StringRoot
			jal printString # Print string

	printFloat:
			li $v0, 2 # Print float
			syscall
			
			addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
			addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
			syscall
			b main		   
	
################################### the SRT procedure it takes $a0 as parameter ##################################
						#f0= Number, f2= 2, f4= 0.5, f6= -0.5, f12=Q, $t2= result of pow

SRT:	move $s1, $a0
	lw $s2, N
	lw $s3, Counter
	
	la $t0,Half
	l.s $f4,($t0)		# f4= 0.5
	la $t1,MinusHalf
	l.s $f6,($t1)		# f6= -0.5
	
	mtc1 $zero, $f12
	# f8=  temp value initially zero 
		
	start:	li $s4,2
		mtc1 $s4,$f2		# from $s2 to $f2 
		cvt.s.w $f2,$f2		# the value in f2 is integer so we convert it to single precision float
		mul.s $f0,$f0,$f2	# multipy the number by 2
			
		c.lt.s $f0,$f4	#compare with 0.5
		bc1f largerThanHalf
		# if here then <0.5 we need to checj if its less than -0.5
		c.lt.s $f0,$f6	#compare with -0.5
		bc1t lessThanMinusHalf
		
		# if here then 0.5 > x >= -0.5
		# qi= 0 only 
		addiu $s3,$s3,1
		beq $s3,$s2,printRes
		j start
	
	largerThanHalf:		# qi= 1 and we'll do subtraction
				#do subtraction => (2Q+ 2^round-1) so (2*$f12 + 2^$s3-1) 
				mul.s $f18,$f2,$f12	# 2 * Q
				#-----------------------------------
				li $a1,2	# 2^round-1
				addiu $a2,$s3,1
				jal pow
				li $t1,1
				mtc1 $t1,$f8		# from $t1 to $f8
				cvt.s.w $f8,$f8		# the value in f8 is integer so we convert it to single precision float
				mtc1 $t2,$f14		# from $t2 to $f14
				cvt.s.w $f14,$f14		# the value in f14 is integer so we convert it to single precision float
				div.s $f20,$f8,$f14	# 
				#-----------------------------------
				# add them 
				add.s $f22,$f18,$f20	# (2Q+ 2^round-1) 
				# subtract 2* Number - (2Q+ 2^round-1)  and save it as new Number
				sub.s $f0,$f0,$f22
				
				# calculate new Q
				add.s $f12,$f12,$f20	# update value of Q
				addiu $s3,$s3,1
				beq $s3,$s2 printRes
				j start
	
	lessThanMinusHalf:	#qi= -1	and we'll do addition

				#do addition => (2Q - 2^round-1) so (2*$f12 - 2^$s3-1) 
				mul.s $f18,$f2,$f12	# 2 * Q
				#-----------------------------------
				li $a1,2	# 2^round-1
				addiu $a2,$s3,1
				jal pow
				li $t1,1
				mtc1 $t1,$f8		# from $t1 to $f8
				cvt.s.w $f8,$f8		# the value in f8 is integer so we convert it to single precision float
				mtc1 $t2,$f14		# from $t2 to $f14
				cvt.s.w $f14,$f14		# the value in f14 is integer so we convert it to single precision float
				div.s $f20,$f8,$f14	# 
				#-----------------------------------
				# add them 
				sub.s $f22,$f18,$f20	# (2Q - 2^round-1) 
				# subtract 2* Number - (2Q+ 2^round-1)  and save it as new Number
				add.s $f0,$f0,$f22
				#------------------------------------------------------------
				# calculate new Q
				sub.s $f12,$f12,$f20	# update value of Q
				addiu $s3,$s3,1
				beq $s3,$s2 printRes
				j start
		 
#######################################################################################			
pow:	move $t0,$a1	# X (base)
	move $t1,$a2	# Y (power)
	li $t2, 1
	li $t3, 1
	
	for:
		beq $t1, $zero, end			#while(n>=1)
		mul $t2, $t2, $t0				#x=*x
		sub $t1, $t1, $t3				#n--
		j for	
	#result is in t2
	end: jr $ra
			
################################################################################
printString:		li $v0, 4 # Print string
			syscall
			jr $ra
					
exit:	# Exit program
	li $v0, 10 
	syscall

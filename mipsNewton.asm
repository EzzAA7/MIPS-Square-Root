# Title: Filename:	Newton algorithm implementation
# Author:Adham Saheb & Ezz Abu Asab	Date:
# Description:
# Input:8 bit integer number (1-255)
# Output:square root of number

###########################################################################################################

#note , double precision numbers take 2 f registers in a row, and always start with an even register number 

.data #data section of the code 

initialMsg: .asciiz      "Hello, Please enter a number !\n" #welcoming string
initValueMsg: .asciiz      "Please take an initial guess for the root\n" #inital guess string
currentPrecision: .asciiz    "Current precision : "
resultMsg: .asciiz      "Result of Square root \n" #result string
divider: .asciiz      "----------------------------------------------\n" #new line with divider string
newLine: .ascii "\n" # new line 

half : .double 0.5
initialGuess : .double 0.5
precision: .double 0.00001


.text #code segment

#print the initial msg to the screen to read the input 8-bit integer
la $a0,initialMsg
jal printString


#reset a0 after reading 
xor $a0,$a0,$a0



#read the integer to find sqaure root to
jal readInt #v0 now contains the integer read 

mtc1.d $v0, $f2 # move integer read to a floating point register $f5 from $v0
cvt.d.w $f2, $f2 # saving the number to a register $f2 since $f12 is high likely to get modified 
 
#print message for input of initial guess
la $a0,initValueMsg
jal printString
#read initial guess 
jal readDouble
s.d $f0,initialGuess
 
 
 ###################################################### Newton Raphson method starts here 
 #this method uses the generic floating point instructions for div and mul, and will guarintee a 10^-6 precision
 #$f2 = N WHERE IS THE NUMBER TO FIND SQRT FOR 
 #NOW FOR THE ITERATIONS BELOW ,THE FOLLOWING NEWTON RAPHSON FORMULA WAS USED : 
 # Y(n+1) = 0.5 (  Y(n) + ( N/Y(n)  )
 # N -> $f2 
 # Y(n) -> $f4 
 # N/Y(N) -> $f6
 # Y(n+1) -> $f8 
 # 0.5 -> half (variable named in data ) -> #f10
 
 

# the following lines will be the first iteration used with the initial guess
 l.d $f10 , half # $f4 will always have a constant 0.5 
 l.d $f20, initialGuess # inital guess 
 div.d $f6,$f2,$f20 # $f6 = N/y(n)
 add.d $f6,$f6,$f20 # $f6 = N/y(n) + y(n)
 mul.d $f4,$f6,$f10 # $f6 = y(n) 

 
 
 #so far, the value of Y(n) is stored in $f4 
 # now iterate for 
 

 newtonLabel: 
 	#perform an iteration
 	mov.d $f22,$f4 # take a copy of the result to compare difference between the last 2 results 
	div.d $f6,$f2,$f4 # $f6= N/Y(n)
 	add.d $f6,$f6,$f4 # $f6 = (N/Y(N)) + Y(n)
 	mul.d $f4,$f6,$f10 # $f4 = y(n+1) to be y(n) ( new one ) 
 	#check precision 
 	sub.d $f30,$f22,$f4 # $f30 = difference between last 2 iterations 
 	l.d $f24,precision # load precision in register
 	c.le.d $f30,$f24 #set the flag register to true if the precision value is reached 
 	#print current precision 
 	la $a0,currentPrecision
 	jal printString 
 	mov.d $f12,$f30
 	jal printDouble
 	#new line 
 	la $a0,newLine
 	jal printString
 	bc1f  newtonLabel
  ###################################################### Newton Raphson method ends here 
  
  
 	
 	#print result msg and divider 
 	la $a0,resultMsg
 	jal printString
 	la $a0,divider
 	jal printString
	#move result to $f12 and print it 
 	mov.d $f12,$f4 
 	jal printDouble
 	

 
 








#This is to terminate the program
li $v0,10
syscall


# next part of the code are the procedures used 
###########################################################################################################
#notes  : 
#integer to print -> $a0
#integer  read -> $v0 
#double to print -> $f12 
#double read -> $f12 
#string to print -> $a0
###########################################################################################################



###############################################################	Double Procedures 
#procedure to print a double from $f12 
printDouble:
	li $v0,3
	syscall 
	jr $ra # return;
	
#procedure to read a double from user , result stored in $f0
readDouble:
	li $v0,7
	syscall 
	jr $ra #return 
#########################################################   End of Double Procedures 



######################################################################	Integer Procedures 	
#procedure to print a integer from $a0 
printInt:
	li $v0,1
	syscall 
	jr $ra # return;
	
#procedure to read a double from user , result stored in $v0
readInt:
	li $v0,5
	syscall 
	jr $ra #return 
##############################################################################   End of Integer Procedures 


		
#procedure to print a string to the screen , need to put string in a0 	
printString:
	li $v0,4       	    # code 4 == print string
	syscall             # Ask the operating system to 
	jr $ra #return 



	

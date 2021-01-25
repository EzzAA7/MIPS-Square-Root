# Title: Filename:	Halley algorithm implementation
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
three : .double 3.0
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
 

 
 


 l.d $f4, initialGuess # inital guess Y(n) initial 
 l.d $f10, three # 3.0 
 
 
  
 ###################################################### Halley's Rational Algorithm starts here 
 #this method uses the generic floating point instructions for div and mul , it has cubic convergance
 
 #$f2 = N WHERE IS THE NUMBER TO FIND SQRT FOR 
 #NOW FOR THE ITERATIONS BELOW ,THE FOLLOWING FORMULA WAS USED : 
 # Y(n+1) = ( Y(n)* (Y(n)^2 + 3N )  ) / (3Y(n)^2 + N)

 #INITIAL GUESS ->  $f20
 # N -> $f2 
 # Y(n) -> $f4 
 # Y(n) ^2 -> $f6
  # 3N -> $f8

#advantage : with good initial guess, very few iterations needed, cubic convergance 
#downs : 
# 5 multiplications and a division in every iteration

#static 
 ori $t1, 5 # number of iterations 
  
 #start iterating 
 
 halleysLabel:
 
 #nominator
 mul.d $f6,$f4,$f4 # $f6 = Y(n)^2
 mul.d $f14,$f10,$f2 # $f14 = 3N
 add.d $f16,$f6,$f14 # $f16 = Y(n)^2 + 3N
 mul.d $f16,$f16,$f4 # $f16 = (Y(n)^2 + 3N)*Y(n)
 
 #denominator
 mul.d $f18,$f10,$f6 # $f18 = 3 * Y(n)^2
 add.d $f20,$f18,$f2 # $f20 = $f18 = 3 * Y(n)^2 + N (Denominator)
 
 #devide nomitator by denominator and save in $f4
 div.d $f4,$f16,$f20
 
 #decrement iterations and check
 addi $t1,$t1,-1 
 bnez $t1,halleysLabel
 
 #print result string 
 la $a0,resultMsg
 jal printString
 
 
 #move answer to f12 to print it 
 mov.d $f12,$f4
 jal printDouble
 
#HALLEY'S ITERATIVE ALGORITHM ENDS HERE
#####################################################################################################


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



	

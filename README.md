# MIPS-Square-Root
MIPS Square-Root Implementation for 8-bit Integer

Square-Root Implementation & Performance Comparisons Square root operation is
considered difficult to implement in hardware, in this project, we wrote and tested
a MIPS assembly language program to implement three algorithms of an 8-bit integer
square root. Background: In mathematics, a square root (√) of a number x is a number
r such that r 2 = x, or, in other words, a number r whose square (the result of
multiplying the number by itself, or r × r) is x. Some of the algorithms for calculating
square roots of a positive Integer number N are shown below:

1. Newton Raphson Method The Newton Raphson method
was first used in Gray-
2. Iterative method starts with an initial (guess) value and improves accuracy of the
result with each iteration.

2. The Radix-2 SRT-Redundant and Non-Redundant Algorithm: 
The Radix-2
SRT-Redundant and Non-Redundant method are similar. Since them both based on
recursive relation. In each iteration, they will be one digit shift left and addition. The
determination of a function is rather complex, especially for high radix SRT
algorithm. The implantations are not capable of accepting a square root on every
clock cycle. Also notice that these two methods may generate a wrong resulting value
at the last digit position.

3. The Non-Restoring Algorithm:
The operation at each iteration is simple: addition
or subtraction based on the result bit generated in previous iteration. The remainder of
the addition or subtraction is fed via registers to the next iteration directly even it is
negative. At the last iteration, if the remainder is non-negative, it is a precise
remainder. Otherwise, we can obtain a precise remainder by an addition operation.

4. Halley Algorithm 

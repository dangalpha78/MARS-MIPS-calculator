.data
	input_prompt: .asciiz "Please insert your expression: "
	invalid_input: .asciiz "You inserted an invalid character in your expression "
	input: .space 100
	newline: .asciiz "\n"
	postfix: .space 400
	operator: .space 400
	
	prompt_postfix: .asciiz "Postfix expression: "
	prompt_result: .asciiz "Result: "
	prompt_quit: .asciiz "Exitting the calculator..."
	stars: .asciiz "****************************************"
	
	converter: .word 1
	wordToConvert: .word 1
	stack: .space 400
.text
main:
	#call input prompt
	li $v0, 4
	la $a0, stars
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, input_prompt
	syscall	
	
	# read input expression
	la $a0, input 
	addi $a1, $0, 100
	li $v0, 8 
	syscall
	
	# Status
	li $s7,0 		# Status 
				# 0 = initially receive nothing
				# 1 = receive number
				# 2 = receive operator
				# 3 = receive (
				# 4 = receive )
				# 5 = receive !
	
	#t0 to track the string index
	li $t0,0
	li $t9,0	#t9 to store digits
	li $t8,0	#t8 to track the postfix size
	li $t6,0	#t6 to track the operator stack index, t5 to help
	li $t5,0	
String_Iterate:
	# t1 is string[i]
	lb $t1, input($t0)
	addi $t0,$t0,1
	
	beq $t1, ' ',String_Iterate  # Skip a blank space ' '
	# End of string
	beq $t1, '\n', Exit
	
	# Read digits
	beq $t1, '0',readDigits
	beq $t1, '1',readDigits
	beq $t1, '2',readDigits
	beq $t1, '3',readDigits
	beq $t1, '4',readDigits
	beq $t1, '5',readDigits
	beq $t1, '6',readDigits
	beq $t1, '7',readDigits
	beq $t1, '8',readDigits
	beq $t1, '9',readDigits
	#beq $t1, '.',readFloat
	
	# Read Operators
	
	beq $t1, '+',PlusMinus
	beq $t1, '-',PlusMinus
	beq $t1, '*',MulDiv
	beq $t1, '/',MulDiv
	beq $t1, '!',Factorization
	beq $t1, '^',Exponential
	# Quit program
	beq $t1, 'q',checkQuit
	
	#beq $t1, '(', openBracket
	#beq $t1, ')', closeBracket
	
Invalid_input:
	li $v0, 4
	la $a0, invalid_input
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, stars
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	j main
	
checkQuit:
	lb $t1, input($t0)
	addi $t0,$t0,1
	bne $t1,'u',Invalid_input
	
	lb $t1, input($t0)
	addi $t0,$t0,1
	bne $t1,'i',Invalid_input
	
	lb $t1, input($t0)
	addi $t0,$t0,1
	bne $t1,'t',Invalid_input
	
	j QuitProgram
			
readDigits:
	beq $s7,4,Invalid_input
	mul $t9,$t9,10
	sub $t1,$t1,'0'
	add $t9,$t9,$t1
	li $s7,1
	j String_Iterate
	
PlusMinus:
	beq $s7,3,Invalid_input	# Wrong if before it is a operator or an open bracket
	beq $s7,2,Invalid_input
	beq $s7,0,Invalid_input	# Receive operator before any number
	jal NumsToPostfix
	li $s7,2
	
	SupportPlusMinus:
	beq $t6,0,inputOperator # If top of operator stack has nothing
	#Else Pop until the operator stack has nothing, because + - has the lowest priority :
	lw $t7, operator($t5) # top of stack
	jal OpsToPostfix
	j SupportPlusMinus

MulDiv:
	beq $s7,3,Invalid_input	# Wrong if before it is a operator or an open bracket
	beq $s7,2,Invalid_input
	beq $s7,0,Invalid_input	# Receive operator before any number	
	jal NumsToPostfix
	li $s7,2
	
	SupportMulDiv:
	beq $t6,0,inputOperator # If top of operator stack has nothing
	# Else pop until meet the lower priority operator
	lw $t7, operator($t5) # top of stack
	beq $t7,'(',inputOperator	# If top is ( --> push into
	beq $t7,'+',inputOperator	# If top is a lower priority operator
	beq $t7,'-',inputOperator
	jal OpsToPostfix
	j SupportMulDiv
Factorization:
	bltz $t9,Invalid_input
	beq $s7,3,Invalid_input	# Wrong if before it is a operator or an open bracket
	beq $s7,2,Invalid_input
	beq $s7,0,Invalid_input	# Receive operator before any number
	
	li $t4,1
	li $s4,1
	beginFacLoop:
	bgt $t4,$t9,endFacLoop
	mul $s4,$s4,$t4
	addi $t4,$t4,1	
	j beginFacLoop
	
	endFacLoop:
	#Store t9
	add $t9,$0,$s4
	
	j String_Iterate
Exponential:
	beq $s7,3,Invalid_input	# Wrong if before it is a operator or an open bracket
	beq $s7,2,Invalid_input
	beq $s7,0,Invalid_input	# Receive operator before any number	
	jal NumsToPostfix
	li $s7,2
	
	SupportExp:
	beq $t6,0,inputOperator # If top of operator stack has nothing
	# Else pop until meet the lower priority operator
	lw $t7, operator($t5) # top of stack
	beq $t7,'(',inputOperator	# If top is ( --> push into
	beq $t7,'+',inputOperator	# If top is a lower priority operator
	beq $t7,'-',inputOperator
	beq $t7,'*',inputOperator	
	beq $t7,'/',inputOperator
	jal OpsToPostfix
	j SupportExp
			
equalPriority: 		# Same operator priority
	jal OpsToPostfix
	j inputOperator
lowerPriority:		# Lower priority than top of operator stack, pop until op stack empty or meet lower priority
	jal OpsToPostfix
# Not finished
# openBracket:
#	beq $s7,1,Invalid_input		# Receive open bracket after a number or close bracket
#	beq $s7,4,Invalid_input
#	
#	li $s7,3

NumsToPostfix:
	sw $t9,postfix($t8) # Store to postfix
	addi $t8,$t8,4
	addi $t9,$0,0 # Reset t9 to 0
	jr $ra
OpsToPostfix:
	addi $t7,$t7,1000000
	sw $t7,postfix($t8)
	addi $t8,$t8,4
	addi $t5,$t5,-4		# Decrease index of top operator stack
	addi $t6,$t6,-4
	jr $ra
inputOperator: 
	sw  $t1,operator($t6)
	addi $t5,$t6,0
	addi $t6,$t6,4
	j String_Iterate
Exit:
	beq $s7,2,Invalid_input		# End with an operator or open bracket
	beq $s7,3,Invalid_input
	beq $s7,0,Invalid_input		# Input nothing
	jal NumsToPostfix
	j popAll
popAll:
	beq $t6,0,finishScan
	lw $t7,operator($t5)
	jal OpsToPostfix
	j popAll
finishScan: # Print postfix
	li $v0, 4
	la $a0, prompt_postfix
	syscall
	li $t4,0	#Set postfix offset to 0
printPost:
	beq $t4,$t8,finishPrint	# If offset == current index
	lw $t7,postfix($t4) 	# Load value of current Postfix
	
	addi $t4,$t4,4
	bgt $t7,1000000,printOps	# If current postfix value is an operator
	#Else:
	li $v0, 1
	add $a0,$t7,$0
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	j printPost
	
	printOps:
	
	li $v0, 11
	addi $t7,$t7,-1000000	# Decode operator
	add $a0,$t7,$zero
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	j printPost
finishPrint:
# Calculate
	li $t4,0	#Set postfix offset to 0
	li $t3,0 	#Stack offset
calPost:
	beq $t4,$t8,printResult
	lw $t7,postfix($t4) 	# Load value of current Postfix
	
	addi $t4,$t4,4
	bgt $t7,1000000,process		# if current index is an operator -> pop 2 numbers to cal
	#Else then t7 is a number
	sw $t7,stack($t3)
	addi $t3,$t3,4
	j calPost
	
	process:
	sub $t7,$t7,1000000	# Decode operator
	beq $t7,43,plus
	beq $t7,45,minus
	beq $t7,42,multiply
	beq $t7,47,divide
	beq $t7,94,exp
	plus:
		sub $t3,$t3,4		#Pop 2 numbers
		lw $s5,stack($t3)
		sub $t3,$t3,4
		lw $s6,stack($t3)
					
		add $s5,$s5,$s6		# process
		
		sw $s5,stack($t3)	# Push again to stack
		addi $t3,$t3,4
		
		j calPost
	minus:
		sub $t3,$t3,4		#Pop 2 numbers
		lw $s5,stack($t3)
		sub $t3,$t3,4
		lw $s6,stack($t3)
		
		sub $s5,$s6,$s5		# process
		
		sw $s5,stack($t3)	# Push again to stack
		addi $t3,$t3,4
		
		j calPost
	multiply:
		sub $t3,$t3,4		#Pop 2 numbers
		lw $s5,stack($t3)
		sub $t3,$t3,4
		lw $s6,stack($t3)
		
		mul $s5,$s6,$s5		# process
		
		sw $s5,stack($t3)	# Push again to stack
		addi $t3,$t3,4
		
		j calPost
	divide:
		sub $t3,$t3,4		#Pop 2 numbers
		lw $s5,stack($t3)
		sub $t3,$t3,4
		lw $s6,stack($t3)
		
		div $s6,$s5		# process
		mflo $s5
		
		sw $s5,stack($t3)	# Push again to stack
		addi $t3,$t3,4
		
		j calPost
		
	exp:
		sub $t3,$t3,4		#Pop 2 numbers
		lw $s5,stack($t3)
		sub $t3,$t3,4
		lw $s6,stack($t3)
		
		addi $t6,$s6,0		# process
		li $t2,1
		
		startExpLoop:
		addi $t2,$t2,1
		mul $s6,$s6,$t6
		beq $t2,$s5,endExpLoop
		j startExpLoop
		
		endExpLoop:
		sw $s6,stack($t3)	# Push again to stack
		addi $t3,$t3,4
		j calPost
printResult:
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, prompt_result
	syscall
	
	li $v0, 1
	lw $a0, stack($0)
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, stars
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	j main	
QuitProgram:
	li $v0, 4
	la $a0, prompt_quit
	syscall

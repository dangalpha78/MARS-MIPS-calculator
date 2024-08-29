.data  
    numPostfix: .space 800
    operatorStack: .space 800
    
    postfixString: .space 800
    postfixOps: .space 800
    
    stack: .space 800
    
    resultString: .space 800
    
    inputString: .space 800
    inputPostfix: .space 800
    
    const0: .double 0
    const1: .double 1
    const10: .double 10
    constOp: .double -1
    beginFac: .double 1
    
    converter: .word 1
    wordToConvert: .word 1
    
    constPlus: .double -2
    constMinus: .double -3
    constMul: .double -4
    constDiv: .double -5
    constExp: .double -6
    constFac: .double -7
    constM: .double -0.5
    
    
    inputPrompt: .asciiz "Please insert your expression:\n"
    
    invalidInput: .asciiz "You inserted an invalid character in your expression\n"
    
    quit: .asciiz "quit\n"
    
    stars: .asciiz "/***************************************************/\n" 
    
    bluhbluh: .asciiz "-----------\n"
  
    newline: .asciiz "\n"
    
    resultPrompt: .asciiz "Result: "
    
    thankyouPrompt: .asciiz "Thank you, goodbye!!!"
    
    postfixPrompt: .asciiz "Postfix: "
    
    fout: .asciiz "calc_log.txt"


.text

	li   $v0, 13       # system call for open file
  	la   $a0, fout     # output file name
  	li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  	li   $a2, 0        # mode is ignored
  	syscall            # open a file (file descriptor returned in $v0)
 	move $s1, $v0
main:
	#divider string in file txt
	li   $v0, 15       # system call for write to file
  	move $a0, $s1      # file descriptor 
  	la   $a1, stars # address of buffer from which to write
  	li   $a2, 54     # hardcoded buffer length
  	syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, newline
  	li   $a2, 1    
  	syscall
  	
  	#divider string in terminal
  	li $v0, 4     	
    	la $a0, stars
    	syscall
	
	#print input prompt
    	li $v0, 4
    	la $a0, inputPrompt
    	syscall
    	
    	#write input prompt to file txt
    	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, inputPrompt  
  	li   $a2, 31     
  	syscall

	#read input string
    	li $v0, 8
    	la $a0, inputString
    	li $a1, 800
    	syscall

    	la $t0, inputString
    	la $t1, quit
    	la $t2, 5
    	
    	l.d $f0,const0($0)   	
	l.d $f2,const1($0)	
	l.d $f4,const10($0)	
	l.d $f30,const0($0)		
	l.s $f29,converter($0)
	l.d $f14, constOp($0)
	l.d $f18, beginFac($0)
	
	li $t5, 0 #postfix size
	li $t6, 0 #index of stack op
	li $t7, 0 #stack op
	
	li $s5, 0
	li $s3, 0 	# 0 = nothing
				# 1 = (+ check
				# 2 = receive num
				# 3 = receive op + - * /

    	li $s4, 0 	#0 nothing
    			#1 is M
    	li $s6, 0	#bracket count
    	li $s7, 0	# .2 .3
    	
    	li $s2, 0 	#string length
continue:
	lb $t3, ($t0)
	lb $t4, ($t1)
    	beq $t3, $t4, quitCheck
    	
	jal convert
	
notValid:
	li $v0, 4
    	la $a0, invalidInput
    	syscall   
    	
    	li   $v0, 15
  	move $a0, $s1      
  	la   $a1, inputString  
  	la   $a2, ($s2)     
  	syscall	
  	
  	li   $v0, 15      
  	move $a0, $s1      
  	la   $a1, newline
  	la   $a2, 1     
  	syscall
    	
    	li   $v0, 15       
  	move $a0, $s1     
  	la   $a1, invalidInput  
  	li   $a2, 53   
  	syscall
		
  	#li   $v0, 15       
  	#move $a0, $s1      
  	#la   $a1, stars
  	#li   $a2, 54    
  	#syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
	la   $a1, newline
  	li   $a2, 1    
  	syscall
    	
	j main
	
printPostfix:
	beq $s7, 3, notValid
	li   $v0, 15      
  	move $a0, $s1      
  	la   $t3, inputString
  	move $a1, $t3
  	addi $s2, $s2, -1
  	la   $a2, ($s2)
  	syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
	la   $a1, newline
  	li   $a2, 1    
  	syscall
  	
  	li $v0, 4
    	la $a0, postfixPrompt
    	syscall
	
	beq $s3, 3, notValid
	jal numsToPost
	popAll:
		beq $t6, 0, finishScan
		lw $t8, operatorStack($t7)
    		jal opsToPost
    		j popAll
    	finishScan:
    		bnez $s6, notValid
    		li $t4, 0
    	printPost:
    		beq $t4, $t5, finishPrint
    		
    		l.d $f8, postfixString($t4)
    		l.d $f30, constOp($0)
    		c.le.d $f8, $f30
    		bc1f printNums		
		
		lw $t9, postfixOps($t4)
		
		li $v0, 11
		add $a0,$t9,$zero
		syscall
		
		beq $t9, '+', plusConvert
		beq $t9, '-', minusConvert
		beq $t9, '*', mulConvert
		beq $t9, '/', divConvert
		beq $t9, '!', facConvert
		beq $t9, '^', expConvert
	
		plusConvert:
		l.d $f14, constPlus($0)
		j encode
	
		minusConvert:
		l.d $f14, constMinus($0)
		j encode
	
		mulConvert:
		l.d $f14, constMul($0)
		j encode
	
		divConvert:	
		l.d $f14, constDiv($0)		
		j encode
	
		facConvert:
		l.d $f14, constFac($0)
		j encode
	
		expConvert:
		l.d $f14, constExp($0)
		j encode
		
		encode:
		s.d $f14, postfixString($t4)
	
		li $v0, 11
		li $a0, ' '
		syscall
		
		addi $t4, $t4, 8
		j printPost
			
		printNums:
		addi $t4, $t4, 8
		l.d $f30, constM
		c.eq.d $f8, $f30
		bc1t printM
		
    		li $v0,3
		add.d $f12,$f8,$f0
		syscall
    		
    		endPrintM:
    		li $v0, 11
		li $a0, ' '
		syscall				
		
		j printPost
		
		printM:
		li $v0, 11
		li $a0, 'M'
		syscall	
		j endPrintM
		
		

convert:
	li $t0, 0
	li $s5, 0
	inConvert:
		lb $t1, inputString($t0)
		addi $t0, $t0, 1
		addi $s2, $s2, 1
		
		beq $t1, '\n', printPostfix
		beq $t1, '0', readDigits
		beq $t1, '1', readDigits
		beq $t1, '2', readDigits
		beq $t1, '3', readDigits
		beq $t1, '4', readDigits
		beq $t1, '5', readDigits
		beq $t1, '6', readDigits
		beq $t1, '7', readDigits
		beq $t1, '8', readDigits
		beq $t1, '9', readDigits
		beq $t1, 'M', readDigits

		beq $t1, '.', readFracPart
		
		beq $t1, '+', readPlus_minus
		beq $t1, '-', readPlus_minus
		beq $t1, '*', readMul_div
		beq $t1, '/', readMul_div
		beq $t1, '!', readFac
		beq $t1, '^', readExp
		
		beq $t1, '(', open
		beq $t1, ')', close
		
		
		
		j notValid
		
readPlus_minus:
	beq $s3, 1, notValid
	bne $s3, 2, notValid
	beq $s7, 3, notValid
	li $s7, 0
	jal numsToPost
	li $s3, 3
	li $s4, 0
	
	supPlus_minus:
	li $s5, 0
	beq $t6, 0, readOperators
	lw $t8, operatorStack($t7)
	beq $t8, '(', readOperators
	jal opsToPost
	j supPlus_minus

readMul_div:
	beq $s7, 3, notValid
	li $s7, 0
	beq $s3, 1, notValid
	bne $s3, 2, notValid
	jal numsToPost
	li $s3, 3
	li $s4, 0
	
	supMul_div:
	li $s5, 0
	beq $t6, 0, readOperators
	lw $t8, operatorStack($t7)
	beq $t8, '(', readOperators
	beq $t8, '+', readOperators
	beq $t8, '-', readOperators
	jal opsToPost
	j supMul_div
	
readFac:
	beq $s7, 3, notValid
	li $s7, 0
	beq $s3, 1, notValid
	#li $s3, 0
	li $s4, 0
	supFac:
	beq $t6, 0, readOperators
	lw $t8, operatorStack($t7)
	beq $t8, '(', readOperators
	beq $t8,'+',readOperators
	beq $t8,'-',readOperators
	beq $t8,'*',readOperators	
	beq $t8,'/',readOperators
	beq $t8, '^', readOperators
	jal opsToPost
	j supFac

readExp:
	beq $s7, 3, notValid
	li $s7, 0
	beq $s3, 1, notValid
	bne $s3, 2, notValid
	jal numsToPost
	li $s3, 3
	li $s4, 0
	
	supExp:
	li $s5, 0
	beq $t6, 0, readOperators
	lw $t8, operatorStack($t7)
	beq $t8, '(', readOperators
	beq $t8, '+', readOperators
	beq $t8, '-', readOperators
	beq $t8, '*', readOperators
	beq $t8, '/', readOperators
	jal opsToPost
	
	j supExp
	
	
open:	
	beq $s7, 3, notValid
	li $s7, 0
	addi $s6, $s6, 1
	li $s3, 1
	j readOperators
close:
	beq $s7, 3, notValid
	li $s7, 0
	beq $s3, 1, notValid
	jal numsToPost
	li $s5, 1
	continueClose:
		beq $t6, 0, notValid
		lw $t8, operatorStack($t7)
		beq $t8, '(', matchBracket
		jal opsToPost
		j continueClose

matchBracket:
	addi $t7, $t7, -8
	addi $t6, $t6, -8
	addi $s6, $s6, -1
	
	j inConvert
	
readOperators:
	sw $t1, operatorStack($t6)
	addi $t7, $t6, 0
	addi $t6, $t6, 8
	j inConvert
readDigits:
	beq $s4, 1, notValid
	li $s7, 1
	bne $t1, 'M', digits
	
	li $s4, 1
	li $s3, 2
	l.d $f30, constM($0)
	
	j inConvert
	
	digits:
	li $s3, 2
	mul.d $f30,$f30,$f4
	jal convertToDouble
	add.d $f30,$f30,$f26
	j inConvert
	
	
convertToDouble:
	sub $t1,$t1,'0'
	sw $t1, wordToConvert($0)
	l.s $f28, wordToConvert($0)
	div.s $f28,$f28,$f29
	cvt.d.s $f26,$f28
	jr $ra
	
readFracPart:
	beq $s4, 1, notValid
	bne $s3, 2, notValid
	li $s7, 3
	l.d $f2, const1($0)
	inFrac:
	lb $t1, inputString($t0)
	beq $t1, '\n', printPostfix
	
  	addi $s2, $s2, 1
	beq $t1, '0',processRFP
	beq $t1, '1',processRFP
	beq $t1, '2',processRFP
	beq $t1, '3',processRFP
	beq $t1, '4',processRFP
	beq $t1, '5',processRFP
	beq $t1, '6',processRFP
	beq $t1, '7',processRFP
	beq $t1, '8',processRFP
	beq $t1, '9',processRFP
	
	beq $t1, '.', notValid
	beq $t1, 'M', notValid
	
	j inConvert
	
	processRFP:
	#process
	li $s7, 1
  	jal convertToDouble
  	mul.d $f2,$f2,$f4
  	
  	div.d $f26,$f26,$f2
  	add.d $f30,$f30,$f26
  	
  	addi $t0,$t0, 1
  	
  	j inFrac

numsToPost:
	beq $s5, 1, next

	s.d $f30, postfixString($t5)
	addi $t5, $t5, 8
	add.d $f30, $f0, $f0
	next:
	jr $ra
	
	
opsToPost:
	s.d $f14, postfixString($t5)
	sw $t8, postfixOps($t5)
	addi $t5, $t5, 8
	addi $t7, $t7, -8
	addi $t6, $t6, -8
	jr $ra
	
	
finishPrint:
	li $v0, 11
	li $a0, '\n'
	syscall	
	
	li $t4, 0
	li $t3, 0
	
	l.d $f8, const0($0)
	add.d $f4, $f20, $f0
	l.d $f2,const1($0)
	
calculation:
	beq $t4, $t5, printResult
    		
    	l.d $f8, postfixString($t4)
    	addi $t4, $t4, 8
    	
    	c.lt.d $f8, $f0
    	bc1t process
    	
    	s.d $f8, stack($t3)
    	addi $t3, $t3, 8
    	j calculation
    	
    	process:
    	l.d $f10, constPlus($0)
    	c.eq.d $f8, $f10
    	bc1t plus
    	
    	l.d $f10, constMinus($0)
    	c.eq.d $f8, $f10
    	bc1t minus
    	
    	l.d $f10, constMul($0)
    	c.eq.d $f8, $f10
    	bc1t multiply
    	
    	l.d $f10, constDiv($0)
    	c.eq.d $f8, $f10
    	bc1t divide
    	
    	l.d $f10, constExp($0)
    	c.eq.d $f8, $f10
    	bc1t exp
    	
    	l.d $f10, constFac($0)
    	c.eq.d $f8, $f10
    	bc1t fac
    	
    	l.d $f10, constM($0)
    	c.eq.d $f8, $f10
    	bc1t calM
    	
    	plus:
    		addi $t3, $t3, -8
    		l.d $f16, stack($t3)
    		addi $t3, $t3, -8
    		l.d $f24, stack($t3)
    		
    		add.d $f16, $f16, $f24
    		
    		s.d $f16, stack($t3)
    		addi $t3, $t3, 8	
    		
    		j calculation
    		
    	minus:
    		addi $t3, $t3, -8
    		l.d $f16, stack($t3)
    		addi $t3, $t3, -8
    		l.d $f24, stack($t3)
    		
    		sub.d $f16, $f24, $f16
    		
    		s.d $f16, stack($t3)
    		addi $t3, $t3, 8
    		
    		j calculation
    	multiply:
    		addi $t3, $t3, -8
    		l.d $f16, stack($t3)
    		addi $t3, $t3, -8
    		l.d $f24, stack($t3)
    		
    		mul.d $f16, $f24, $f16
    		
    		s.d $f16, stack($t3)
    		addi $t3, $t3, 8
    		
    		j calculation
    	divide:
    		addi $t3, $t3, -8
    		l.d $f16, stack($t3)
    		addi $t3, $t3, -8
    		l.d $f24, stack($t3)
    		
    		div.d $f16, $f24, $f16
    		
    		s.d $f16, stack($t3)
    		addi $t3, $t3, 8
    		
    		j calculation
    	exp:
		sub $t3,$t3,8		# Pop 2 numbers
		l.d $f12,stack($t3)	# B
		
		# Check if B is a integer
		cvt.w.d $f10,$f12	# f10 have the int value of f12
		mfc1.d $s5,$f10
		bltz $s5, notValid
		
		cvt.d.w $f10,$f10
		c.eq.d $f10,$f12
	
		bc1t continueExp
		j notValid
			
		continueExp:	
		sub $t3,$t3,8
		l.d $f10,stack($t3)
		
		li $t2,0
		l.d $f14,const1($0)
		
		startExpLoop:
		addi $t2,$t2,1
		mul.d  $f14,$f14,$f10
		beq $t2,$s5,endExpLoop
		j startExpLoop
		
		endExpLoop:
		s.d $f14,stack($t3)	# Push again to stack
		addi $t3,$t3,8
    		
    		j calculation
    		
	fac:
		addi $t3, $t3, -8
    		l.d $f30, stack($t3)
    		
    		
    		mov.d $f20, $f30
	
		c.le.d $f20, $f0
		bc1t notValid
		
		cvt.w.d $f30, $f20
		cvt.d.w $f22, $f30
		c.eq.d $f20, $f22
		bc1f notValid
		
		l.d $f18, beginFac($0)
		l.d $f16, const1($0)
		beginFacLoop:
		c.le.d $f18, $f30
		bc1f endFacLoop
		mul.d $f16, $f16, $f18
		add.d $f18, $f18, $f2
		
		j beginFacLoop
		endFacLoop:
		s.d $f16, stack($t3)		
		addi $t3, $t3, 8
    				
    		j calculation
    	
    	calM:
    		s.d $f4, stack($t3)
    		addi $t3, $t3, 8
    		
    		j calculation
    		
quitCheck:
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t2, $t2, -1
	beq $t2, $zero, end
	j continue

newLine:
	li $v0, 11
	li $a0, '\n'
	syscall
	
	j main
	
printResult:	
	li $v0, 4
	la $a0, resultPrompt
	syscall
	
	li $v0, 3
	l.d $f12, stack($0)
	l.d $f20, stack($0)
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
doubleToString:
	li $t2, 10
	li $t3, 0
	li $t4, 0
	li $t5, 0
	
	negative:
	c.lt.d $f12, $f0
	bc1t storeNegative
	
	endNegative:
	cvt.w.d $f10, $f12
	
	mfc1 $t1, $f10
	
	mtc1.d $t1, $f10
	cvt.d.w $f10, $f10	
	
	
	intToString:
		storeToStack:
		div $t1, $t2
		mflo $t1
		mfhi $t3
		
		sw $t3, stack($t4)
		beqz $t1, storeToResult
		addi $t4, $t4, 4
		
		j storeToStack
		
	storeToResult:
		
		lw $t3, stack($t4)		
		
		addi $t3, $t3, 48
				
		sb $t3, resultString($t5)
		
		addi $t5, $t5, 1
		beqz $t4, storeDot
		addi $t4, $t4 -4
		
		j storeToResult
		
	storeDot:
		addi $t3, $0, '.'
		sb $t3, resultString($t5)
		addi $t5, $t5, 1
	
	
		li $t4, 16
		l.d $f4,const10($0)	
	storeFrac:
		beqz $t4, printLog
		
		li $t1, 0
		li $t3, 0
		
		sub.d $f12, $f12, $f10
		
		mul.d $f16, $f12, $f4
		
		add.d $f12, $f16, $f0
		
		cvt.w.d $f16, $f16
		
		mfc1 $t1, $f16
		
		mtc1.d $t1, $f10
		cvt.d.w $f10, $f10
		
		addi $t1, $t1, 48
		sb $t1, resultString($t5)
		
		addi $t5, $t5, 1
		addi $t4, $t4 -1
		
		j storeFrac
		
	storeNegative:
		addi $t3, $0, '-'
		sb $t3, resultString($t5)
		addi $t5, $t5, 1
		
		sub.d $f12, $f0, $f12
	j endNegative
		
		
printLog:
	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, bluhbluh
  	li   $a2, 12     
  	syscall
  	
  	li   $v0, 15      
  	move $a0, $s1      
  	la   $a1, resultPrompt 
  	li   $a2, 8     
  	syscall
  	
  	li $t1, 0
  	li $t3, 0
  	printResultString:
  	beq $t1, $t5, endPrintRes
  	li $v0, 15
  	move $a0, $s1
  	la $t3, resultString($t1)
  	move $a1, $t3
  	li $a2, 1
  	syscall
  	
  	addi $t1, $t1, 1
  	j printResultString
  	
  	endPrintRes:
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, newline 
  	li   $a2, 1     
  	syscall
  	
  	#li   $v0, 15      
  	#move $a0, $s1      
  	#la   $a1, stars 
  	#li   $a2, 54     
  	#syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, newline
  	li   $a2, 1   
  	syscall
  	
  	j main

end:

	li $v0, 4     	
    	la $a0, thankyouPrompt
    	syscall

	li $v0, 4     	
    	la $a0, newline
    	syscall

	li $v0, 4     	
    	la $a0, stars
    	syscall

	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, quit  
  	li   $a2, 5     
  	syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, thankyouPrompt
  	li   $a2, 21   
  	syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, newline
  	li   $a2, 1   
  	syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, newline
  	li   $a2, 1   
  	syscall
  	
  	li   $v0, 15       
  	move $a0, $s1      
  	la   $a1, stars
  	li   $a2, 54    
  	syscall

	li   $v0, 16       # system call for close file
  	move $a0, $s1      # file descriptor to close
  	syscall 
  	
    	li $v0, 10
    	syscall
    	
    	


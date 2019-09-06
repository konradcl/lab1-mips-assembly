  # hexmain.asm
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

	.text
main:
	li	$a0, 17		# $a0 = 0, change this to test different values

	jal	hexasc		# call hexasc
	nop			# delay slot filler (just in case)	

	move	$a0, $v0	# $a0 = $v0, copy return value to argument register

	li	$v0, 11		# syscall with v0 = 11 will print out
	syscall			# ascii character in a0 to the Run I/O window
	
	li	$v0, 10		# system exit code
	syscall			# terminates execution, no garbage memory will be executed

hexasc:	
	# $a0 = $a0 & 0xF
	# if ($a0 > 9) $v0 = $a0 + 0x37
	# else $v0 = $a0 + 0x30
	
	addi 	$t1, $0, 9		# $t1 = 9 (bound between numbers and letters)
	andi 	$a0, $a0, 0xF		# 28 zeros concatinated with the last 4 bits of $a0				
	
	bgt 	$a0, $t1, gt9		# branch to gt9, if $a0 > 9
	
	addi 	$v0, $a0, 0x30		# convert $a0 to ascii code for 0-9
	jr 	$ra				

gt9:
	addi $v0, $a0, 0x37		# convert $a0 to ascii code for A-F
	jr $ra

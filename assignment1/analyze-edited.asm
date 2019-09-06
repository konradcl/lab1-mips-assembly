  # analyze.asm
  # This file written 2015 by F Lundevall
  # Copyright abandoned - this file is in the public domain.

	.text
main:
	li	$s0,48		# $s0 = 48
loop:
	move	$a0,$s0		# $a0 = $s0 = 48
	
	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# prints ASCII character defined by a0 to Run I/O window
	
	addi	$s0,$s0,3	# $s0 = $s0 + 3
	
	li	$t0,90		# t0 = 90
	bne	$s0,$t0,loop	# if ($s0 != $t0) loop
	nop			# delay slot filler (just in case)

stop:	j	stop		# loop forever here
	nop			# delay slot filler (just in case)

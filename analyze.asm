  # analyze.asm
  # This file written 2015 by F Lundevall
  # Copyright abandoned - this file is in the public domain.

	.text
main:
	li	$s0,0x30	# $s0 = 48
loop:
	move	$a0,$s0		# $a0 = $s0 = 48
	
	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# one byte from a0 to the Run I/O window (ONE CHARACTER?)

	addi	$s0,$s0,1	# what happens if the constant is changed?
	
	li	$t0,0x5b	# t0 = 91
	bne	$s0,$t0,loop	# if ($s0 != $t0) loop
	nop			# delay slot filler (just in case)

stop:	j	stop		# loop forever here
	nop			# delay slot filler (just in case)

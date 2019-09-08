  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0, 1000	# $a0 = 1000
	jal	delay		# wait for $a0 ms
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

# Returns an ASCII code to $v0 for one of the characters 0-9 or A-F based on the value of
# the four least significant bits of $a0. The mapping between the value of the four least
# significant digits of $a0 and the characters 0-9 and A-F is: {(0, 0), (1, 1), ... (15, F)}.
hexasc:	
	# $a0 = $a0 & 0xF
	# if ($a0 > 9) $v0 = $a0 + 0x37
	# else $v0 = $a0 + 0x30
	
	addi 	$t1, $0, 9		# $t1 = 9 (bound between numbers and letters)
	andi 	$a0, $a0, 0xF		# 28 zeros concatinated with the last 4 bits of $a0				
	
	bgt 	$a0, $t1, gt9		# branch to gt9, if $a0 > 9
	
	addi 	$v0, $a0, 0x30		# convert $a0 to ascii code for 0-9
	jr 	$ra				
	nop

gt9:
	addi $v0, $a0, 0x37		# convert $a0 to ascii code for A-F
	jr $ra
  	nop
  
delay:
	sgt	$t2, $a0, $0		# $t2 = $a0 > $0 ? 1 : 0
	beqz	$t2, end_delay		# if ($t2 == 0) branch to end_delay
	nop
	subi	$a0, $a0, 1		# $a0 -= 1

	li	$s0, 0			# $s0 = 0
	li	$t0, 50			# $t0 = 26 (delay constant, 1 tick is approx 1 s)
delay_loop:	
	slt	$t1, $s0, $t0		# $t1 = $s0 < $t0 ? 1 : 0
	beqz	$t1, end_delay_loop	# if ($t1 == 0) branch to end_delay_loop
	nop
	addi	$s0, $s0, 1		# $s0 += 1		
	j	delay_loop
end_delay_loop:
	j	delay
	nop
end_delay:
	jr	$ra			# return
	nop

# $a0 = memory address for time2string output
# $a1 = The 16 least significant bits contain time-info, organized as four NBCD-coded 
# 	digits of 4-bits. 16 most significant bits are arbitrary
# return value: none
#
# time2string writes the following sequence of six characters to the area in
# memory pointed to by $a0, IN THE GIVEN ORDER:
#	1. Two ASCII-coded digits showing the number of minutes, according to
#	   the two most significant NBCD-coded digits of $a1.
#	2. A colon character. 
#	3. Two ASCII-coded digits showing the number of seconds, according to
#	   the two least significant NBCD-coded digits of $a1.
#	4. A null byte.
time2string:
	# Extract NBCD-coded minutes/seconds from $a1.
	andi 	$t0, $a1, 0xF000	# $t0 = zeros concat with most significant
	sra	$t0, $t0, 12		# NBCD-coded digit (tens of minutes)
	andi	$t1, $a1, 0xF00		# $t1 = zeros contact with second most significant
	sra	$t1, $t1, 8		# NBCD-coded digit (minutes)
	andi	$t2, $a1, 0xF0		# t2 = zeros concat with second lest significant
	sra 	$t2, $t2, 4		# NBCD-coded digit (tens of seconds)
	andi	$t3, $a1, 0xF		# t3 = zeros concat with least significant
					# NBCD-coded digit (seconds)
					
	# Save necessery overwritten constants.
	move	$t4, $a0	# $t4 = memory address for time2string output
	PUSH	($ra)		# push return address to main to stack
	PUSH	($t1)		# push NBCD-coded minutes digit to stack
	
	# Convert NBCD-coded minutes/seconds to ASCII-coded digits.
	# Arrange ASCII-coded minutes/seconds into the above specified sequence of
	# characters in the area of memory pointed to by $t4 = $a0.
	move 	$a0, $t0	# a0 = NBCD-coded tens of minutes digit
	jal	hexasc		# $v0 = ASCII-coded tens of minutes digit
	nop
	sb	$v0, 0($t4)	# store 8 least significant bits of $v0 at mem[reg($t4)]
	
	POP	($t1)		# $t1 = NBCD-coded minutes digit
	move	$a0, $t1	# $a0 = NBCD-coded minutes digit
	jal	hexasc		# $v0 = ASCII-coded minutes digit
	nop
	sb	$v0, 1($t4)	# store 8 least significant bits of $v0 at 
				# mem[reg($t4 + sgnxt(1)]
	
	li	$t6, 0x3A	# $t6 = ASCII-code for colon
	sb	$t6, 2($t4)	# store 8 least significant bits of $t6 at
				# mem[reg($t4 + sgnxt(2)]				
										
	move 	$a0, $t2	# $a0 = NBCD-coded tens of seconds digit
	jal	hexasc		# $v0 = ASCII-coded tens of seconds digit
	nop
	sb	$v0, 3($t4)	# store 8 least significant bits of $v0 at
				# mem[reg($t4 + sgnxt(2)]
				
	move	$a0, $t3	# $a0 = NBCD-coded seconds digit
	jal	hexasc		# $v0 = ASCII-coded seconds digit
	nop	
	sb	$v0, 4($t4)	# store 8 least significant bits of $v0 at
				# mem[reg($t4 + sgnxt(3)]
				
	li	$t6, 0x00	# $t6 = ASCII-code for NUL
	sb	$t6, 5($t4)	
	
	POP	($ra)		# $ra = return address to main
	jr	$ra
	nop
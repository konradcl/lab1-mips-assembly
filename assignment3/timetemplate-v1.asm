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
	la	$a0, timstr	# $a0 = memory address of timstr
	li	$v0, 4		# $v0 = syscode 4 for printing null-terminated string
	syscall			# print null-terminated string at address $a0
	nop
	# wait a little
	li	$a0, 2		# $a0 = 2
	jal	delay
	nop
	# call tick
	la	$a0, mytime	# $a0 = input time
	jal	tick		# update time pointed by $a0	
	nop
	# call your function time2string
	la	$a0, timstr	# $a0 = memory address of timestr	
	la	$t0, mytime	# $t0 = memory address of time
	lw	$a1, 0($t0)	# $a1 = time
	jal	time2string	# convert time to string
	nop
	# print a newline
	li	$a0, 10		# ascii new line code
	li	$v0, 11		# $v0 = syscode for printing character represented by $a0
	syscall			# print new line
	nop
	# go back and do it all again
	j	main
	nop
	
# tick: update time pointed to by $a0
tick:	lw	$t0, 0($a0)	# get time
	addiu	$t0, $t0, 1	# increase time by 1 s
	andi	$t1, $t0, 0xf	# check lowest digit
	sltiu	$t2, $t1, 0xa	# if digit < a, okay
	bnez	$t2, tiend
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

hexasc:	
	addi 	$t1, $0, 9	# $t1 = 9 (bound between numbers and letters)
	andi 	$a0, $a0, 0xF	# 28 zeros concatinated with the last 4 bits of $a0				
	
	bgt 	$a0, $t1, gt9	# branch to gt9, if $a0 > 9
	
	addi 	$v0, $a0, 0x30	# convert $a0 to ascii code for 0-9
	jr 	$ra				
	nop

gt9:
	addi 	$v0, $a0, 0x37	# convert $a0 to ascii code for A-F
	jr 	$ra
	nop
	
delay:
	jr	$ra
	nop
	
time2string:	
	# $a0 = memory address of timestr
	# $a1 = time value (in 16 least significant bits)
	
	andi 	$t0, $a1, 0xF		# seconds, bits 0-3 of $a1
	andi 	$t1, $a1, 0xF0		# tens of seconds, bits 4-7 of $a1
	srl	$t1, $t1, 4		# $t1 = $t1 >> 4
	andi 	$t2, $a1, 0xF00		# minutes, bits 8-11 of $a1
	srl	$t2, $t2, 8		# $t2 = $t2 >> 8
	andi 	$t3, $a1, 0xF000	# tens of minutes, bits 12-15 of $a1
	srl	$t3, $t3, 12		# $t3 = $t3 >> 12
	move	$t4, $a0		# $t4 = memory address of timestr 
					#     = output memory address
	move 	$t5, $ra		# $t5 = return address to main
	
	# write seconds to timestr
	move	$a0, $t0		# $a0 = $t0
	jal	hexasc
	nop
	sb	$v0, 0($t4)		# set bits 0-3 of $t4 to ascii code for reg($t0)
	
	# write tens of seconds to timestr
	move 	$a0, $t1
	jal	hexasc
	nop
	sb 	$v0, 1($t4)		# set bits 4-7 of $t4 to ascii code for reg($t1)

	# write : to timestr
	li	$a0, 0x3A		# #a0 = ascii code for :
	sb	$a0, 2($t4)		# set bits 8-11 of $t4 to ascii code for :

	# write minutes to timestr
	move	$a0, $t2
	jal 	hexasc
	nop	
	sb	$v0, 3($t4)		# set bits 12-15 of $t4 to ascii code for reg($t2)
	
	# write tens of minutes to timestr
	move	$a0, $t3
	jal	hexasc
	nop	
	sb	$v0, 4($t4)		# set bits 16-19 of $t4 to ascii code for reg($t3)

	# write null byte to timestr
	li	$a0, 0x00
	sb	$a0, 5($t4)		# set bits 20-23 of $t4 to ascii code for null byte
	
	# return
	jr	$t5
	nop
	
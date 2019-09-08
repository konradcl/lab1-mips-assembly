# void delay( int ms ) /* Wait a number of milliseconds, specified by the parameter value. */
# {
# 	int i;
# 	while( ms > 0 )
# 	{
# 		ms = ms – 1;
# 		/* Executing the following for loop should take 1 ms */
# 		for( i = 0; i < 4711; i = i + 1 ) /* The constant 4711 must be easy to change! */
# 		{
# 			/* Do nothing. */
# 		}
#	}
# }

# Wait a number of milliseconds as specified by $a0.
.text
	li 	$a0, 1000		# $a0 = 1000 ms
	jal 	delay
	nop

delay:
	sgt	$t2, $a0, $0		# $t2 = $a0 > $0 ? 1 : 0
	beqz	$t2, end_delay		# if ($t2 == 0) branch to end_delay
	subi	$a0, $a0, 1		# $a0 -= 1

	li	$s0, 0			# $s0 = 0
	li	$t0, 4711		# $t0 = 4711
delay_loop:
	slt	$t1, $s0, $t0		# $t1 = $s0 < $t0 ? 1 : 0
	beqz	$t1, end_delay_loop	# if ($t1 == 0) branch to end_delay_loop
	addi	$s0, $s0, 1		# $s0 += 1		
	j	delay_loop
end_delay_loop:
	j	delay
end_delay:
	jr	$ra			# return
	nop
	

# Lab 1 – Notes

### Assignment 1

How do the contents of the registers `$s0` and `$a0` change during execution?

- `$s0` changes from `0x30 = 48` to `0x5b = 91`, in increments of 1 for each loop.
- `$a0` changes from `0x30 = 48` to `0x5a = 90`, in increments of 1 for each loop. It does not reach 91 because the program no longer jumps back to `loop` when `$s0 = $t0 = 91`.

<br/>

What changes need to be made so that every third character is printed?

- Change `addi $s0, $s0, 1` to `addi $s0, $s0, 3`.
- Change `$t0 = 90 || 93 || other number divisble by 3 `.

<br/>

What happens if the constant `1 ` is changed in`addi $0, $0, 1` in the program?

- If the constant is set to $n$, then every $n$th character is printed. Note that the program will enter an infinite loop if `$s0` never becomes equal to `$t0`. Accordingly, you may also want to modify `$t0` to prevent this from happening.

<br/>

Why do we have an infinite loop at `stop`?

- The purpose of the infinite loop is to prevent the processor from proceeding to execute code in garbage memory. All memory except your code and that which your code writes to is garbage, aka undefined. So without the infinite loop, the instruction pointer will enter a garbage area after your code. Then, potentially the computer could start executing code that is not part of my program, but that is present in memory right after my program
- ==In MIPS we can also exit with `syscall` when `$v0 = 10`, why not use this instead?==



### Assignment 2

Your subroutine `hexasc` is called with an integer-value as an argument in register `$a0`, and returns a return-value in register `$v0`. If the argument is 17, what is the return-value? Why?

- If the argument `$a0` is initialized to $17_{10} = 10001_2$, then the return value is $1$ because the four least significant bits of `$a0` are equal to $1$.

<br/>

If your solution contains a conditional-branch instruction: which input values cause the
instruction to actually branch to another location? This is called a taken branch.

- Input values where the four least significant bits represent a value greater than 9 cause the program to take the branch.



### Assignment 3

`time2string` **contract**

- [ ] Parameter 1: `$a0` – memory address for output of `time2string`
- [ ] Parameter 2: `$a1` – input time-info
  - [ ] 16 least significant bits are time-info organized as four NBCD-coded digits (tens of minutes, minutes, tens of seconds, seconds).
  - [ ] The 16 most significant bits can have any values and must be ignored.
- [ ] Return value: none
- [ ] Required action: Write the following six characters to the register pointed to by `$a0`
  - [ ] Two ASCII-coded digits showing the number of minutes, according to the two more significant NBCD-coded digits of `$a1`.
  - [ ] A colon character (ASCII code 0x3A).
  - [ ] Two ASCII-coded digits showing the number of seconds, according to the two less significant NBCD-coded digits of `$a1`.
  - [ ] A null byte (ASCII code 0x00).
- [ ] Use `hexasc` to convert each NBCD-coded digit into the corresponding ASCII code.
- [ ] Use `sb` to store each byte at the destination register.
- [ ] Save and restore registers according to convention.



Which registers are saved and restored by your subroutine? Why?



Which registers are used but not saved? Why are these not saved?



Assume the time is 16:53. Which lines of your code handle the '5'?


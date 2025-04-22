.data 
input:      .space 1001
.align 2
strint:     .space 4000
nullstr:    .asciiz "NULL"
.align 2
buffer:     .space 11

.text
.globl main

main:
    # Read input string
    addi $v0, $zero, 8
    la $a0, input
    addi $a1, $zero, 1000
    syscall

    la $t3, input
strip_newline:
    lb $t4, 0($t3)
    beq $t4, $zero, end_strip
    addi $t5, $zero, 10 #ascii for newline
    bne $t4, $t5, not_newline
    sb $zero, 0($t3)
    j end_strip

not_newline:
    addi $t3, $t3, 1
    j strip_newline

end_strip:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $a0, input
    la $a1, strint
    jal process_string

    add $t0, $v0, $zero #t0= count
    la $t1, strint #pointer to result array
    addi $t2, $zero, 0 #index = 0

print_loop:
    beq $t2, $t0, exit 
    lw $t3, 0($t1)
    lui $t4, 0x7FFF
    ori $t4, $t4, 0xFFFF # null
    beq $t3, $t4, print_null

    add $a0, $t3, $zero
    addi $v0, $zero, 1
    syscall
    j check_last

print_null:
    la $a0, nullstr
    addi $v0, $zero, 4
    syscall

check_last:
    addi $t2, $t2, 1
    addi $t1, $t1, 4
    beq $t2, $t0, exit

    addi $a0, $zero, 59 #ascii ';'
    addi $v0, $zero, 11
    syscall
    j print_loop

exit:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    addi $v0, $zero, 10
    syscall

process_string:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    add $s0, $a0, $zero #s0= input pointer
    add $s1, $a1, $zero #s1= result array pointer
    addi $s2, $zero, 0 #substring count = 0

next_chunk:
    la $t3, buffer # substring buffer
    addi $t0, $zero, 0 #char index = 0
    
    addi $t8, $zero, 10

clear_loop:
    sb $zero, 0($t3) #use t3 directly
    addi $t3, $t3, 1
    addi $t8, $t8, -1
    bnez $t8, clear_loop
    sb $zero, 0($t3) # null terminate the buffer
    la $t3, buffer #reset t3 to start of buffer

fill_loop:
    lb $t4, 0($s0)
    beq $t4, $zero, pad_spaces
    sb $t4, 0($t3)

    addi $s0, $s0, 1
    addi $t3, $t3, 1
    addi $t0, $t0, 1
    slti $t5, $t0, 10
    bne $t5, $zero, fill_loop

    j process_substring

pad_spaces:
    addi $t4, $zero, 32 #space
    sb $t4, 0($t3)

    addi $t3, $t3, 1
    addi $t0, $t0, 1
    slti $t5, $t0, 10
    bne $t5, $zero, pad_spaces

process_substring:
    la $a0, buffer
    jal get_substring_value
    sw $v0, 0($s1) #store result in array
    addi $s1, $s1, 4
    addi $s2, $s2, 1
    lb $t6, 0($s0)
    bnez $t6, next_chunk

end_process:
    add $v0, $s2, $zero
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

get_substring_value:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t0, buffer
    addi $t1, $zero, 0 #index
    addi $t2, $zero, 0 #count valid
    addi $t3, $zero, 0 # G sum
    addi $t4, $zero, 0 # H sum
    addi $t6, $zero, 5 #half substring length

next_char:
    lb $t5, 0($t0)
    beq $t5, $zero, compute
    addi $t7, $zero, 48 #'0'
    addi $t8, $zero, 57 # '9'
    slt $t9, $t5, $t7
    bne $t9, $zero, check_upper
    slt $t9, $t8, $t5
    bne $t9, $zero, check_upper
    sub $t9, $t5, $t7
    j store_digit

check_upper:
    addi $t7, $zero, 65 # 'A'
    addi $t8, $zero, 81 # 'Q'
    slt $t9, $t5, $t7
    bne $t9, $zero, check_lower
    slt $t9, $t8, $t5
    bne $t9, $zero, check_lower
    sub $t9, $t5, $t7
    addi $t9, $t9, 10
    j store_digit

check_lower:
    addi $t7, $zero, 97 # 'a'
    addi $t8, $zero, 113 # 'q' #22ndth lowercase letter
    slt $t9, $t5, $t7
    bne $t9, $zero, skip
    slt $t9, $t8, $t5
    bne $t9, $zero, skip
    sub $t9, $t5, $t7
    addi $t9, $t9, 10
    j store_digit

skip:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    slti $t8, $t1, 10
    bne $t8, $zero, next_char
    j compute

store_digit:
    addi $t2, $t2, 1 #count valid digits
    slti $t8, $t1, 5
    bne $t8, $zero, add_G
    add $t4, $t4, $t9 #add to sum H
    j continue_loop

add_G:
    add $t3, $t3, $t9

continue_loop:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    slti $t8, $t1, 10
    bne $t8, $zero, next_char
    j compute

compute:
    beq $t2, $zero, no_valid
    sub $v0, $t3, $t4
    j done

no_valid:
    lui $v0, 0x7FFF
    ori $v0, $v0, 0xFFFF 
    
done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

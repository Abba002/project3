.data 
input:      .space 1001
strint:     .space 4000
newline:    .asciiz "\n"
nullstr:    .asciiz "NULL"

.text
.globl main

main:

# Read input string
li $v0, 8
la $a0, input
li $a1, 1000
syscall

la $a0, input
la $a1, strint
jal process_string

move $t0,$v0 #t0= count
la $t1, strint #pointer to result array
li $t2, 0 #index = 0

print_loop:
beq $t2, $t0, exit 
lw $t3, 0($t1)
li $t4, 0x7FFFFFFF # null
beq $t3, $t4, print_null

move $a0, $t3
li $v0, 1
syscall

print_null:
la $a0, nullstr
li $v0, 4
syscall

check_last:
addi $t2, $t2, 1
addi $t1, $t1, 4
beq $t2, $t0, exit

li $a0, 59 #ascii ';'
li $v0, 11
syscall
j print_loop

exit:
li $v0, 10
syscall

process_string:
move $s0, $a0 #s0= input pointer
move $s1, $a1 #s1= result array pointer
li $s2, 0 #substring count = 0

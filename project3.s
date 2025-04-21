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

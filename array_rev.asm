#===============================================================================
# A basic program in MIPS that accepts user input first of the size of the array
# then the user enters size number of integerr and it prints the reverse of
# the given number and finds and prints the maximum number
# Author: Zachary Baklund
# Date Last Modified: 2017-11-20
#===============================================================================
        .data			
rev:    .asciiz "Reverse: "     # String literal
        .align 2                # Align to the next mult. of 4 bytes
max:    .asciiz "\nMaximum: "   # String literal
        .align 2                # Align to the next mult. of 4 bytes
arr:    .space 400              # int arr[100] = ?
        .align 2                # Align to the next mult. of 4 bytes
        .text			
main:   addi $v0, $zero, 5      # $v0 = user decided size of the array
        syscall                 # Syscall for integer read
#===============================================================================
# Read and store user inputed integers in the array
#===============================================================================
        add $s0, $zero, $zero   # i = 0
        add $s1, $zero, $v0     # $s1 = amt of integers
        la $s2, arr             # $s2 = base address of arr
L:      slt $t0, $s0, $s1       # $t0 = (i < amt) ? 1 : 0
        beq $t0, $zero, LEnd    # !(i < amt) -> LEnd
        addi $v0, $zero, 5      # arr[i] = $v0
        syscall                 # Syscall for integer read
        sll $t0, $s0, 2         # $t0 = i * 4
        add $t0, $s2, $t0       # $t0 =  arr + i * 4
        sw $v0, 0($t0)          # $v0 = arr[i]
        addi $s0, $s0, 1        # i = i + 1
        j L                     # Restart loop
LEnd:   la $a0, rev             # $a0 = base address of string literal
        addi $v0, $zero, 4      # Prep to print string
        syscall                 # Print "Reverse: "
#===============================================================================
# Reverse print
#===============================================================================
        add $s0, $zero, $zero   # i = 0
        addi $s0, $s1, -1       # i = amt - 1
R:      slt $t0, $s0, $zero     # $t0 = (0 < i) ? 1 : 0
        bne $t0, $zero, REnd    # !(0 < i) -> REnd
        sll $t0, $s0, 2         # $t0 = i * 4
        add $t0, $s2, $t0       # $t0 = arr + i * 4
        lw $a0, 0($t0)          # $a0 = arr[i]
        addi $v0, $zero, 1      # Prep to print int
        syscall                 # Print arr[i]
        addi $a0, $zero, 32     # $a0 = ' '
        addi $v0, $zero, 11     # Prep for print char
        syscall                 # Print ' '
        addi $s0, $s0, -1       # i = i + 1
        j R                     # Restart loop
REnd:   la $a0, max             # $a0 = base address of string literal
        addi $v0, $zero, 4      # Prep to print string
        syscall                 # Print "\nMaximum: "
#===============================================================================
# Maximum print
#===============================================================================
        add $s0, $zero, $zero   # $s0 i = 0
        lw $s3, 0($s2)          # $s3 max = arr[0]
MaxL:   slt $t0, $s0, $s1       # $t0 = (i < amt) ? 1 : 0
        beq $t0, $zero, MaxE    # !(i < amt) => MaxE
        sll $t0, $s0, 2         # $t0 = i * 4
        add $t0, $s2, $t0       # $t0 = arr + i * 4
        lw $t1, 0($t0)          # $t1 = arr[i]
        slt $t0, $s3, $t1       # $t0 = (max < arr[i]) ? 1 : 0
        beq $t0, $zero, MaxJ    # !(max < arr[i]) => MaxE
        add $s3, $zero, $t1     # max = arr[i]
MaxJ:   addi $s0, $s0, 1        # i = i + 1
        j MaxL                  # Restart loop
MaxE:   add $a0, $zero, $s3     # $a0 = max
        addi $v0, $zero, 1      # Prep to print for int
        syscall                 # Print max
#===============================================================================
# Clean exit
#===============================================================================
        addi $v0, $zero, 10     # Setup for clean exit
        syscall                 # Clean exit
	

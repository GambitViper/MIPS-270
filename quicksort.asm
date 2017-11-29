#================================================================================
# A MIPS program that uses an implementation of quicksort to sort an array of
# integeres in ascending order. The values will be given as standard input
# first number in the input will specify the number of values in the array
# followed by the values themselves
# Author: Zachary Baklund
# Date Last Modified: 11-27-17
#================================================================================
        .data
arr:    .space 80               # Allocate space for 20 integers
        .align 2                # Align to the next mult of 4 bytes
text:   .asciiz "Sorted: "      # String literal
        .align 2                # Align to the next mult of 4 bytes
        .text
main:   addi $v0, $zero, 5      # $v0 = user decided size of the array
        syscall                 # Syscall for integer read
#---------------------------------
# Read and store user inputed integers in the array
#---------------------------------
        add $s0, $zero, $zero   # $s0 = i = 0 ( iterator )
        add $s1, $zero, $v0     # $s1 = amt of integers ( length ) of the array
        la $s2, arr             # $s2 = base address of arr ( arr ) base address
L:      slt $t0, $s0, $s1       # $t0 = (i < amt) ? 1 : 0
        beq $t0, $zero, LEnd    # !(i < amt) -> LEnd
        addi $v0, $zero, 5      # arr[i] = $v0
        syscall                 # Syscall for integer read
        sll $t0, $s0, 2         # $t0 = i * 4
        add $t0, $s2, $t0       # $t0 =  arr + i * 4
        sw $v0, 0($t0)          # $v0 = arr[i]
        addi $s0, $s0, 1        # i = i + 1
        j L                     # Restart loop
LEnd:   add $a0, $zero, $s2     # Setup arg 0 of qsort call
        add $a1, $zero, $s1     # Setup arg 1 of qsort call
        jal qsort               # quick_sort( arr, length );
#---------------------------------
# Print loop
#---------------------------------
        la $a0, text            # $a0 = base address of string literal
        addi $v0, $zero, 4      # Prep to print string
        syscall                 # Print "Sorted: "
        add $s0, $zero, $zero   # $s0, i = 0 ( iterator )
R:      slt $t0, $s0, $s1       # $t0 = (i < amt) ? 1 : 0
        beq $t0, $zero, REnd    # !(i < amt) -> REnd
        sll $t0, $s0, 2         # $t0 = i * 4
        add $t0, $s2, $t0       # $t0 = arr + i * 4
        lw $a0, 0($t0)          # $a0 = arr[i]
        addi $v0, $zero, 1      # Prep to print int
        syscall                 # Print arr[i]
        addi $a0, $zero, 32     # $a0 = ' '
        addi $v0, $zero, 11     # Prep for print char
        syscall                 # Print ' '
        addi $s0, $s0, 1        # i = i + 1
        j R                     # Restart loop
#--------------------------------
# Clean exit
#--------------------------------
REnd:   addi $v0, $zero, 10     # Setup for clean exit
        syscall                 # Clean exit
#--------------------------------------------------------------------------------
# Initiates the recursive call to the quicksort of a given array - arr[]
# C declaration:        void quick_sort(int arr[], int length);
#--------------------------------
qsort:  addi $sp, $sp, -4      # Space for $ra
        sw $ra, 0($sp)         # Store return address
#--------------------------------
        addi $a2, $a1, -1      # qsortH argument ( int right = length - 1 )
        add $a1, $zero, $zero  # qsortH argument ( int left = 0 )
        jal qsortH             # Call quick_sort_helper(arr, 0, length - 1)
#--------------------------------
        lw $ra, 0($sp)         # Restore $ra
        addi $sp, $sp, 4       # Pop stack
        jr $ra                 # Return
#--------------------------------------------------------------------------------
# Quicksort recursive method compares left and right to the partition
# C declaration:        void quick_sort_helper(int arr[], int left, int right);
#--------------------------------
qsortH: addi $sp, $sp, -20     # Space for $ra and $s0 index
        sw $ra, 16($sp)        # Store return address
        sw $s0, 12($sp)        # Caller agreement store $s0 = index
        sw $a0, 8($sp)         # Store $a0 base arr address
        sw $a1, 4($sp)         # Store $a1 left
        sw $a2, 0($sp)         # Store $a2 right
#--------------------------------
        jal parter             # Call partition( arr, left, right)
        lw $a0, 8($sp)         # Restore $a0 base arr address
        lw $a1, 4($sp)         # Restore $a1 left
        lw $a2, 0($sp)         # Restore $a2 right
        add $s0, $zero, $v0    # $s0n index = partition( arr, left, right);
        addi $t1, $s0, -1      # $t1 = index - 1
        slt $t0, $a1, $t1      # $t0 = ( left < index - 1 ) ? 1 : 0
        beq $t0, $zero, not1   # !( left < index - 1 ) => notl
        add $a2, $zero, $t1    # Setup arg 2 for qsortH call
        jal qsortH             # Recurse qsortH(arr, left, index -1)
not1:   slt $t0, $s0, $a2      # $t0 = ( index < right ) ? 1 : 0
        beq $t0, $zero, not2   # !( index < right ) => not2
        add $a1, $zero, $s0    # Setup arg 1 for qsortH call
        jal qsortH             # Recurse qsortH(arr, index, right)
#--------------------------------
not2:   lw $ra, 16($sp)        # Restore return address
        lw $s0, 12($sp)        # Restore $s0
        addi $sp, $sp, 20      # Pop stack
        jr $ra                 # Return        
#--------------------------------------------------------------------------------
# Partition method to make a pivot and perform a partition
# C declaration:        int partition(int arr[], int left, int right);
#--------------------------------
parter: addi $sp, $sp, -20     # Space for $ra, i, j, tmp, and pivot
        sw $ra, 16($sp)        # Store return address
        sw $s0, 12($sp)        # Caller agreement store $s0 = i
        sw $s1, 8($sp)         # Caller agreement store $s1 = j
        sw $s2, 4($sp)         # Caller agreement store $s2 = pivot
        sw $s3, 0($sp)         # Caller agreement store $s3 = tmp
#--------------------------------
        add $s0, $zero, $a1    # $s0 = i = left
        add $s1, $zero, $a2    # $s1 = j = right
        add $t0, $a1, $a2      # $t0 = left + right
        srl $t0, $t0, 1        # $t0 = ( left + right ) / 2
        sll $t0, $t0, 2        # $t0 = (( left + right ) / 2) * 4                                                           
        add $t0, $a0, $t0      # $t0 = arr + ( ( left + right ) / 2 )
        lw $s2, 0($t0)         # $s2 = pivot = arr[ ( left + right ) / 2 ]
pLoop:  slt $t0, $s1, $s0      # $t0 = ( j < i ) ? 1 : 0
        bne $t0, $zero, pEnd   # !( j < i ) -> pEnd
pL1:    sll $t0, $s0, 2        # $t0 = i * 4
        add $t0, $a0, $t0      # $t0 =  arr + i * 4 
        lw $t0, 0($t0)         # $t0 = arr[i]
        slt $t0, $t0, $s2      # $t0 = (arr[i] < pivot) ? 1 : 0
        beq $t0, $zero, pL2    # !(arr[i] < pivot) => pL2
        addi $s0, $s0, 1       # $s0 = i = i + 1
        j pL1                  # Restart loop
pL2:    sll $t0, $s1, 2        # $t0 = j * 4
        add $t0, $a0, $t0      # $t0 = arr + j * 4
        lw $t0, 0($t0)         # $t0 = arr[j]                                     ?????????
        slt $t0, $s2, $t0      # $t0 = (pivot < arr[j]) ? 1 : 0
        beq $t0, $zero, pLE    # !(pivot < arr[j]) => pLE
        addi $s1, $s1, -1       # $s1 = j = j - 1
        j pL2                  # Restart loop
pLE:    slt $t0, $s1, $s0      # $t0 = ( j < i ) ? 1 : 0
        bne $t0, $zero, pEnd   # !( j < i ) -> pEnd
        sll $t0, $s0, 2        # $t0 = i * 4
        add $t0, $a0, $t0      # $t0 =  arr + i * 4 
        lw $s3, 0($t0)         # $s3 tmp = arr[i]
        sll $t1, $s1, 2        # $t0 = j * 4
        add $t1, $a0, $t1      # $t0 = arr + j * 4
        lw $t2, 0($t1)         # $t0 = arr[j]
        sw $t2, 0($t0)         # arr[i] = arr[j]
        sw $s3, 0($t1)         # arr[j] = tmp
        addi $s0, $s0, 1       # $s0 = i = i + 1
        addi $s1, $s1, -1      # $s1 = j = j - 1
        j pLoop                # Restart parent loop
#--------------------------------
pEnd:   add $v0, $zero, $s0    # Setup return number
        lw $ra, 16($sp)        # Restore $ra
        lw $s0, 12($sp)        # Restore $s0
        lw $s1, 8($sp)         # Restore $s1
        lw $s2, 4($sp)         # Restore $s2 
        lw $s3, 0($sp)         # Restore $s3
        addi $sp, $sp, 20      # Pop stack
        jr $ra                 # Return
        

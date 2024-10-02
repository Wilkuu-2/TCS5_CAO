

#  == Macro's ===

.macro sysc(%id) # Calls a syscall with the certain id
   addi $v0, $zero, %id
   syscall
.end_macro

.macro syscr(%r)
   addu $v0, $zero, %r 
   syscall
.end_macro 

.eqv sys_read_char, sysc(12)
.macro sys_exit(%code) # Exits with a specific error code
   addi $a0, $0, %code
   sysc(17) # exit(2)
.end_macro

.macro sys_println_int(%int_reg) # Prints integer and a newline
   addi $a0, %int_reg, 0
   sysc(1)  # print_int 
   addi $a0, $0, '\n'
   sysc(11) # print_char
.end_macro 

.macro sys_println_hex(%int_reg) # Prints integer and a newline
   addi $a0, %int_reg, 0
   sysc(34)  # print_int_hex
   addi $a0, $0, '\n'
   sysc(11) # print_char
.end_macro 



# == Data section == 
.data
 N: .word 8
 L: .word 12
 
 Inputs: # All other space is reserved for the inputs


# == Registers == 
.eqv InPtr, 	 $s0
.eqv one,   	 $s1    # One 
.eqv rL,    	 $s2		# Size of bitstring, limited by memory and size of integers 
.eqv rN,    	 $s3		# Amount of input bytestrings, limited by memory 
.eqv stringSZ,   $s4  	# Size of a single bitstring in bytes (L / 8, rounded up )
.eqv inputBufSZ, $s5	# Size of the input buffer  (N * stringSZ)  
.eqv minus_one   $t6
.eqv eight       $t7

.eqv iter0  	 $t6
.eqv iter1  	 $t7
.eqv iter2  	 $t8
.eqv newline     $t9 

.text 
  main: 
  addi one, $0, 1 
  addi minus_one, $0, -1 
  addi eight, $0, 8
  addi newline, $0, '\n' 	   # also 10 in decimal
  
  # Load L into register 
  la rL, L
  lw rL, (rL)  
  
  # Load N into register
  la rN, N
  lw rN, (rN)  
  
  la InPtr, Inputs
  
  # Calculate stringSZ
  srl stringSZ, rL, 3     # Reduce L from bits to bytes
  andi $t0, rL, 0x07 # Get the remainder   
  beqz $t0, sz_calc_end
  addi stringSZ, stringSZ, 1   # Add 1 byte for the remainder 
  sz_calc_end: 
  
  # Calculate InputBufSZ 
  mul inputBufSZ, stringSZ, rN # Assumes that all bytestrings fit in memory at the same time (inputBufSZ < size of the address space)
  
  # -- Input -- 
  # Put in the bytestring in byte alligned hex (case insensitive) 
    
  addi iter0, InPtr, 0
  addu iter1, iter0, inputBufSZ
  
  .eqv char_num_high     $t1 
  .eqv char_lowc_high    $t2
  .eqv char_lowc_low     $t3
  .eqv char_uprc_high    $t4
  .eqv char_uprc_low     $t5
  
  addi char_num_high , $0, ':'
  addi char_lowc_high, $0, 'f'
  addi char_lowc_low , $0, '`' 
  addi char_uprc_high, $0, 'F' 
  addi char_uprc_low,  $0, 'A' 
  
  
  decode_byte:
  addi $v1, $0, 0
  addi iter2, $0, -1
  
  decode_hex:  
  sll $v1, $v1, 4 
  
  sys_read_char
  
  blt  $v0, char_num_high, number 
  blt  $v0, char_lowc_low,  uppercase 
  bgt  $v0, char_lowc_high, invalid_char
  subi $v0, $v0, 0x20 # Difference between upper and lower case in ascii
  uppercase: 
 
  bgt  $v0, char_uprc_high, invalid_char 
 
  blt  $v0, char_uprc_low, invalid_char # We already checked for numbers
  addi $v1, $v1, 10 	      # A letter means that the number is above 10 
  subi $v0, $v0, 0x11         # Shift to number space and handle from there
  number: 
  subi $v0, $v0, 0x30         # Convert ascii to actual number 
  addu $v1, $v1, $v0          # Add the number to v1, out output
  b hex_decode_done
  nop
  invalid_char:
  lw $0, 1($0)                # Your input is worth nothing, you should kill yourself NOW 
  
  hex_decode_done: 
  addu iter2, iter2, one   
  blt iter2, one, decode_hex
  # END OF LOOP decode_hex
  
  # Debug 
  #addi $a0, $0, '\n'
  #sysc(11) # print_char
  #sys_println_hex($v1) 
  
  # Store result 
  sb $v1, (iter0)
  
  addu iter0, iter0, one
  blt iter0, iter1, decode_byte
  # END OF LOOP decode_byte  
    
  .eqv byte_off          $t1 
  .eqv L_left            $t2
  .eqv bits_left         $t3

  
  .eqv count             $v1 
  
  .eqv bA                $a1
  .eqv bB                $a2
  
  
  addu $a0, $0, newline            # Put results on a new line
  addu $v0, newline, one 
  syscall
   
  # == Begin of calculations ==
  
  addu iter0, $0, stringSZ
  loopA: 			   # >> for (int iter0 = stringSZ; iter0 < inputBufSZ; iter0 += stringSZ)
  
  addu iter1, $0, $0
  loopB: 		           # >> for (int iter1 = 0       ; iter1 < inputBufSZ; iter1 += stringSZ)

  
  addu byte_off, $0, $0
  addu L_left  , rL, $0
  addu count   , $0, $0
  
  byte_dist:                       # >> for(int byte_off =0); byte_off < stringSZ; byte_off++)  
  addu $t0, byte_off, iter0
  addu $t0, $t0, InPtr
  lbu   bA, ($t0)
  
  addu $t0, byte_off, iter1
  addu $t0, $t0, InPtr
  lbu   bB, ($t0)
  
  sub  bits_left, L_left, eight 
  bltz bits_left, small_byte
  addu bits_left, $0, eight
  bltz minus_one, full_byte
  
  small_byte:
  addu bits_left, $0, L_left
  
  full_byte: 
  sub L_left, L_left, bits_left
  
  bit_count:                       # >> for(int bits_left = min(8, L_left); bits_left > 0; bits_left++)  
  addu $t0, bA, bB                 # Addition on the lowest bit works the same as xor 
  andi $t0, $t0, 1                 # Extract only the LSB 
  
  addu count, count, $t0           # Add xor(lsbA, lsbB)
   
  srl  bA, bA, 1                   # Shift the bA window 
  srl  bB, bB, 1                   # Shift the bB window 
  
  sub bits_left, bits_left, one
  sub $t0, $0, bits_left 
  bltz $t0, bit_count
  # END OF LOOP bit_count 
  
  add byte_off, byte_off, one
  sub $t0, byte_off ,stringSZ 
  bltz $t0, byte_dist
  # END OF LOOP BYTE_DIST
   
  addu $v0, $0, one
  addu $a0, $0, count  
  syscall
  addu $a0, $0, newline
  addu $v0, one, newline 
  syscall 
  
  addu iter1, iter1, stringSZ 
  sub $t0, iter1, iter0
  bltz $t0, loopB 
  # END OF LOOP ITERB
  
  
  addu iter0, iter0, stringSZ 
  sub $t0, iter0, inputBufSZ
  bltz $t0, loopA
  # END OF LOOP ITERA, end of calculations  
  
  addu $v0, $0, newline
  addu $a0, $0, $0 
  syscall 
  
 # bltz 
 # sub 
 # addu 
 # srl 
 # andi
 # syscall # Might not count towards the count
 # lbu
 
    
    
  

CC := gcc
CCOPTS := -Wall 
MARSOPTS := nc 

1_hamming: 1_hamming.c
	${CC} ${CCOPTS} 1_hamming.c -o 1_hamming

tool_mars_adapter: tool_mars_adapter.s
	${CC} ${CCOPTS} tool_mars_adapter.c -o tool_mars_adapter

part1: 
	1_hamming 31 71 298231

part2: 
	echo -e "Put in your bitstrings in byte aligned hex: 1010 0101 1100 0000 becomes\n A5C0 for example.\n"  
	tool_mars_adapter | Mars ${MARSOPTS} 2_hamming.S


clean: 
	rm -rf 1_hamming tool_mars_adapter 

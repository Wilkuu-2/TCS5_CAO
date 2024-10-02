CC := gcc
CCOPTS := -Wall 
MARSOPTS := nc me  
BUILD_DIR := build

${BUILD_DIR}: 
	mkdir ./build
	
${BUILD_DIR}/1_hamming: 1_hamming.c ${BUILD_DIR}
	${CC} ${CCOPTS} 1_hamming.c -o ${BUILD_DIR}/1_hamming 
	
${BUILD_DIR}/tool_mars_adapter: tool_mars_adapter.c ${BUILD_DIR}
	${CC} ${CCOPTS} tool_mars_adapter.c -o ${BUILD_DIR}/tool_mars_adapter 

define \n

endef

P1Ls := 64 89 256
P1Ns := 100 1000
P1Seed := 232345
HAMMING_CMDS := $(foreach L, ${P1Ls}, $(foreach N, ${P1Ns}, ${BUILD_DIR}/1_hamming ${L} ${N} ${P1Seed};${\n})) 


part1: build/1_hamming 
	${HAMMING_CMDS}

part2: build/tool_mars_adapter
	@echo -e "Put in your bitstrings in byte aligned hex: 1010 0101 1100 0000 becomes\n A5C0 for example.\nDon't forget to press enter afterwards!"  
	${BUILD_DIR}/tool_mars_adapter | Mars ${MARSOPTS} 2_hamming.S

clean: 
	rm -rf ${BUILD_DIR}/1_hamming ${BUILD_DIR}/tool_mars_adapter 

#include <stdio.h>

// This is a tool to make the behaviour of the Mars get character syscall consistent between the simulator and the command line
// The command line behaviour requires a newline every character input, which is not fine. 
// This piece of code inserts that newline
// usage: tool_mars_adapter | Mars program.m

#define BUF_SZ 512

int main(void) { 
  char buffer[BUF_SZ]; 
  while((nbytes = read(buffer, BUF_SZ, stdin)) > 0) { //read from the input 
    for(int i = 0; i < nbytes; i++) {
      printf("%c\n", buffer[i]) // Output a newline for each character
    } 
  }

}




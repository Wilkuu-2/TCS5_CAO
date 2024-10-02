#include <unistd.h>
#include <stdio.h>

// This is a tool to make the behaviour of the Mars get character syscall consistent between the simulator and the command line
// The command line behaviour requires a newline every character input, which is not fine. 
// This piece of code inserts that newline
// usage: tool_mars_adapter | Mars program.m

#define BUF_SZ 512

int main(void) { 
  int character; 
  while((character = getc(stdin)) != EOF) { //read from the input
    putchar(character);
    putchar('\n');
    fflush(stdout);
  }

}




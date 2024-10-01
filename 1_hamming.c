#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

// #define FANCY // Pretty printing progress

#define eprintf(...) fprintf (stderr, __VA_ARGS__)
int stride = 1; 
int rand_size;
int L = 8;


// Quick algorithm to create random bit strings 
void rand_bitstr(unsigned char* begin) {
  int i = 0; 
  while(i < L){
    if((L - i) > rand_size) {
      int random = rand();
      memcpy(begin + i/8, &random, rand_size/8);
      i += rand_size;
    } else {
      // Rand one byte
      int rest = L - i;
      unsigned char random = rand(); 
      if (rest < 8) {
        random &= ((1 << (rest + 1)) -1);
      } else {
        rest = 8; 
      }
      memcpy(begin+i/8, &random,1);

      i += rest; 
    }
  //printf("i=%d", i);
  }
  //printf("\n");
} 

int hamming_distance(int L, unsigned char* a, unsigned char* b) {
  int dist = 0; 
  // We do some extra lookups here (stride * 8 might be more than L), but the extra bits are set to 0 in both a and b, so the distance is the same.
  // TODO: Optimise by using ints/longs to xor instead of bytes.
  for(int i = 0; i < stride; i++) {
    unsigned char x = a[i] ^ b[i];
    while(x > 0){
      dist += x & 0x1; 
      x >>= 1;
    }
  }
  return dist;
}

int ilog2(int x) {
  int o = 0;
  while (x > 0) {
    x >>= 1; 
    o++; 
  }  
  return o; 
}


#define pc(a) putc(a,stdout)
void printprogress(int i, int n, int sw){
#ifdef FANCY
  int bar_l = sw-12;
  float progress = (float) (i+1)/ (float) n;
  int bar_p = bar_l * progress; 
  pc('\r');
  pc('[');
  
  for(int i = 0; i < bar_l; i++){
    pc(i < bar_p ? '#' : ' '); 
  }

  printf("] %3.2f%%", progress*100.0f);
#endif /* ifdef FANCY */
}



int main(int argc, char *argv[])
{
  if(argc < 4) {
    eprintf("Too little arguments. Usage:\n%s <Length of strings>, <Number of strings>, <seed>", argv[0]) ;
    return 1;
  } 

  L = atoi(argv[1]);
  int N = atoi(argv[2]);
  int s = atoi(argv[3]);
  srand(s);
  
  // always power of 2, 16 on x86 
  int log2rand = ilog2(RAND_MAX);
  rand_size = log2rand - log2rand % 8; // Calculate the log2 of randmax to know how many bytes we can fill using rand() at the same time. 

  stride = L/8 + (L % 8 != 0);  // Get the amount of bytes that the string can be represented in. 
  unsigned char* inputs = malloc(stride*N);
  long long checksum = 0;


  putc('\n', stdout);
  rand_bitstr(inputs);  
  for(long i = 1; i < N; i++){ 
    int index_i = stride*i; 
    rand_bitstr(inputs +index_i); 
    printprogress(i,N,50);
    for(long j = 0; j < i; j ++ ){
      checksum += hamming_distance(L, inputs +index_i, inputs + stride*j);
    }
  }
  #ifdef FANCY
  putc('\n', stdout);
  #endif

  double average = (double)checksum/(double)(N*N/2-N); 

  #ifdef FANCY
  printf("Done!\nInputs:\nL=%d,N=%d,s=%d\nOutputs:\nChecksum=%lld,Average=%f",L,N,s,checksum,average);
  #else 
  printf("%d,%d,%d,%lld,%f",L,N,s,checksum,average);
  #endif /* ifdef FANCY */

   
  return 0;
}


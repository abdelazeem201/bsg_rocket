// The following is a RISC-V program to test the functionality of the
// RoCC accumulator

//#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

int accum_verify(bool a, bool b, bool c ) { return (a&b&c)?0:1; }

int main() {
  uint64_t x = 123, y = 456, z1 = 0, z2=0, z3=0 ;
  printf("z1=z2=z3=%d\n",z1);
  // load x into accumulator 2 (funct=0)
  asm volatile ("custom0 x0, %0, 2, 0" : : "r"(x));
  // read it back into z (funct=1) to verify it
  asm volatile ("custom0 %0, x0, 2, 1" : "=r"(z1));
  printf("z1=%d\n",z1);
  //assert(z == x);

  //accumulate 456 into it (funct=3)
  asm volatile ("custom0 x0, %0, 2, 3" : : "r"(y));
  // verify it
  asm volatile ("custom0 %0, x0, 2, 1" : "=r"(z2));
  printf("z2=%d\n",z2);
  //assert(z == x+y);

  //do it all again, but initialize acc2 via memory this time (funct=2)
  asm volatile ("custom0 x0, %0, 2, 2" : : "r"(&x));
  asm volatile ("custom0 x0, %0, 2, 3" : : "r"(y));
  asm volatile ("custom0 %0, x0, 2, 1" : "=r"(z3));
  printf("z3=%d\n",z3);
  //assert(z == x+y);

  printf("success!\n");
  return accum_verify(z1==x,z2==x+y,z3==x+y);
}

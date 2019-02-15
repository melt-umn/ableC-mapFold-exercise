#include <stdlib.h>
#include <stdio.h>

/* This files makes use of a working `map` language constructs that 
   maps a function across all elements of an array.

   First, build the ableC instance that processes this file and run it
   on this program.  Try to understand what the constructs are
   supposed to do.

   Next, take a look at the implementation of `map` and understand at
   least the concrete syntax and what the abstract syntax forwards to.
   The error checking can wait a bit.

   Now, see if you can add the destructive map `map!` and array
   folding `fold` operators.  There use below is commented out.
   You'll need to design the concrete syntax, abstract syntax, etc.
   The implementation of `map` will be a good guide.
   
   Don't hesitate to ask questions!
*/ 

#define N 5

int f(int n) {
  return n * n;
}

int f1(int n) {
  return 2 * n;
}

int g(int n, int m) {
  return n + m;
}

int main(void) {
  int *a = malloc(N * sizeof(int));
  for (int i=0; i < N; ++i) {
    a[i] = i;
  }

  int *a1 = map f a N;
  // forwards to:
  //({ int *tmp_a = a;
  //   int *result = malloc(N * sizeof(int));
  //   for (int i=0; i < N; ++i) {
  //     result[i] = f(tmp_a[i]);
  //   }
  //   result;
  //});

  for (int i=0; i < N; ++i) {
    printf("1: a1[%d] = %d\n", i, a1[i]);
  }

  int *a2 = map f (map f1 a N) N;
  // naively forwards to:
  //({ int *tmp_a =
  //    ({ int *tmp_a = a;
  //       int *result = malloc(N * sizeof(int));
  //       for (int i=0; i < N; ++i) {
  //         result[i] = f1(tmp_a[i]);
  //       }
  //       result;
  //    });
  //   int *result = malloc(N * sizeof(int));
  //   for (int i=0; i < N; ++i) {
  //     result[i] = f(tmp_a[i]);
  //   }
  //   result;
  //});

  // optimized forwards to:
  // forwards to:
  //({ int *tmp_a = a;
  //   int *result = malloc(N * sizeof(int));
  //   for (int i=0; i < N; ++i) {
  //     result[i] = f(f1(tmp_a[i]));
  //   }
  //   result;
  //});

  for (int i=0; i < N; ++i) {
    printf("2: a2[%d] = %d\n", i, a2[i]);
  }

/* 
  map! f a N;
  // forwards to:
  //({ int *tmp_a = a;
  //   for (int i=0; i < N; ++i) {
  //     tmp_a[i] = f(tmp_a[i]);
  //   }
  //   tmp_a;
  //});

  for (int i=0; i < N; ++i) {
    printf("3: a[%d] = %d\n", i, a[i]);
  }

  map! f (map! f1 a N) N;
  // naively forwards to:
  //({ int *tmp_a =
  //    ({ int *tmp_a = a;
  //       for (int i=0; i < N; ++i) {
  //         tmp_a[i] = f1(tmp_a[i]);
  //       }
  //       tmp_a;
  //    });
  //   for (int i=0; i < N; ++i) {
  //     tmp_a[i] = f(tmp_a[i]);
  //   }
  //   tmp_a;
  //});

  // optimized forwards to:
  //({ int *tmp_a = a;
  //   for (int i=0; i < N; ++i) {
  //     tmp_a[i] = f(f1(tmp_a[i]));
  //   }
  //   tmp_a;
  //});

  for (int i=0; i < N; ++i) {
    printf("4: a[%d] = %d\n", i, a[i]);
  }

  int g1 = fold g 1, a N;
  // forwards to:
  //({ int result = 1;
  //   int tmp_a = a;
  //   for (int i=0; i < N; ++i) {
  //     result = g(result, tmp_a[i]);
  //   }
  //   result;
  //});
  printf("5: g1 = %d\n", g1);
  
  int g2 = fold g 1, (map f a N) N;
  // naively forwards to:
  //({ int result = 1;
  //   int *tmp_a =
  //    ({ int *tmp_a = a;
  //       int *result = malloc(N * sizeof(int));
  //       for (int i=0; i < N; ++i) {
  //         result[i] = f(tmp_a[i]);
  //       }
  //       result;
  //    });
  //   for (int i=0; i < N; ++i) {
  //     result = g(result, tmp_a[i]);
  //   }
  //   result;
  //});

  // optimized forwards to:
  //({ int result = 1;
  //   int *tmp_a = a;
  //   for (int i=0; i < N; ++i) {
  //     result = g(result, f(tmp_a[i]));
  //   }
  //   result;
  //});

  printf("6: g2 = %d\n", g2);

  // Type errors:
  // map g a N;
  // map f (map f a 2) 3;
  // fold f 0, a N;
  // fold g 0, (2) N;

*/

  return 0;
}


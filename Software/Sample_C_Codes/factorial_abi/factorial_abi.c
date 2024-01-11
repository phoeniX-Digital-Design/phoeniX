#include <stdio.h>

extern int factorial(int x, int y);

int main()
{
    int result = 1;
    int n = 10;
    result = factorial(0x1, n - 1);
    // printf("Result of %d! is %d", n, result);
    return 0;
}
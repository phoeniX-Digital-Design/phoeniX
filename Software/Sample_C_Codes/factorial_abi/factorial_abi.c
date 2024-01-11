#include <stdio.h>

extern int factorial(int x, int y);

int main()
{
    int result = 1;
    int count = 3;
    result = factorial(0x1, count);
    // printf("Result of %d! is %d", count, result);
    return 0;
}
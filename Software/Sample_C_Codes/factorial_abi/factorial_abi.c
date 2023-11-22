#include <stdio.h>

extern int factorial(int x, int y);

int main()
{
    int result = 1;
    int count = 5;
    result = factorial(0x1, count);
    return 0;
}
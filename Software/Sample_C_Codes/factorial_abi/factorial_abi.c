#include <stdio.h>

extern int factorial(int x, int y);

int main()
{
    int result = 1;
    int count = 10;
    result = factorial(0x1, count + 1);
    return 0;
}
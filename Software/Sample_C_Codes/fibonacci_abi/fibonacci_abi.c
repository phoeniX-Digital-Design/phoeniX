#include <stdio.h>

extern int fibonacci(int x, int y);

int main()
{
    int result = 1;
    int count = 10;
    result = fibonacci(0x0, count + 1);
    return 0;
}
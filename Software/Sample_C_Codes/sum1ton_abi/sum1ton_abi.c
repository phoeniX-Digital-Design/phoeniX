#include <stdio.h>

extern int sum1ton(int x, int y);

int main()
{
    int result = 0;
    int count = 100;
    result = sum1ton(0x0, count + 1);
    return 0;
}
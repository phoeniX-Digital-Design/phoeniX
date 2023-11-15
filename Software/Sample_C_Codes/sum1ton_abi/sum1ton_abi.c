#include <stdio.h>

extern int load(int x, int y);

int main()
{
    int result = 0;
    int count = 10;
    result = load(0x0, count + 1);
    return 0;
}
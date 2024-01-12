#include <stdio.h>

int main()
{
    int sum = 0;
    int n = 100;
    
    for (int i = 1 ; i <= n ; ++i)
    {
        sum += i;
    }
    printf("Sum of 1 to %d is %d!", n, sum);
    return 0;
}

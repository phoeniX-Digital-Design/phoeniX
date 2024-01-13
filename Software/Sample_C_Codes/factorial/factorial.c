#include <stdio.h>

int main()
{
    int result = 1;
    int n = 5;
      
    for (int i = 1; i <= n; i++)
    {
        result *= i;
    }

    printf("Result of %d! is %d\n", n, result);
    return 0;
}
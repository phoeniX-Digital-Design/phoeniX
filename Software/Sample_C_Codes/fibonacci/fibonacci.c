#include <stdio.h>

int main()    
{    
    int n1 = 0;
    int n2 = 1;
    int n3;
    int count = 7;

    for(int i = 2; i < count; i++)     
    {    
        n3 = n1 + n2;    
        n1 = n2;    
        n2 = n3;    
    }  

    //printf("\nNumber %d result of Fibonacci sequence is %d\n", count, n3);
    return 0;  
}
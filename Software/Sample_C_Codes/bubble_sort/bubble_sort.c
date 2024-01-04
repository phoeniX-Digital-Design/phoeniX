#include <stdbool.h>
#include <stdio.h>
  
void swap(int* xp, int* yp)
{
    int temp = *xp;
    *xp = *yp;
    *yp = temp;
}
  
// An optimized version of Bubble Sort
void bubble_sort(int arr[], int n)
{
    int i, j;
    bool swapped;
    for (i = 0; i < n - 1; i++) 
    {
        swapped = false;
        for (j = 0; j < n - i - 1; j++) 
        {
            if (arr[j] > arr[j + 1]) 
            {
                swap(&arr[j], &arr[j + 1]);
                swapped = true;
            }
        }
        // If no two elements were swapped by inner loop,
        // then break
        if (swapped == false)
            break;
    }
}
  
// Function to print an array
void print_array(int arr[], int size)
{
    int i;
    for (i = 0; i < size; i++)
        printf("%d ", arr[i]);
}
  
// Driver program to test above functions
int main()
{
    int arr[] = {8, 3, 5, 1, 7, 2, 4};
    int n = sizeof(arr) / sizeof(arr[0]);
    printf("Unsorted array:\n");
    print_array(arr, n);
    printf("\n");
    bubble_sort(arr, n);
    int min = arr[0];
    printf("Sorted array:\n");
    print_array(arr, n);
    return 0;
}
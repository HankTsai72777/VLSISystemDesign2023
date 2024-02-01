// Insertion Sort
#include <stdint.h>

extern unsigned int array_size;
extern short array_addr;
// extern short *array = &array_addr;
const short* array = &array_addr;
extern short _test_start;
short* dest = &_test_start;

void insertionSort() {
   /*int i, j;
    int key;

    for (i = 0; i < array_size; i++) {
        key = array[i];
        j = i+1;
        // Move elements of array[0..i-1] that are greater than key to one position ahead of their current position
        while (j >= 0 && dest[j] > key) {
            dest[j + 1] = dest[j];
            j = j - 1;
        }

        dest[j + 1] = key;
    }*/

    int i, j;
    int temp;
    for (i = 1; i < array_size; i++)
    {
        temp = dest[i]; //將第i個元素複製到temp做插入排序的動作
        j = i -1;     //當次最後一個為i元素，由後向前做排序(i-1 to 0)
        for (; j >= 0 && dest[j] > temp; j--) //從後向前做比較 
        {
            dest[j + 1] = dest[j];             //將較大的元素通通向右方做shift的動作
        }
        dest[j+1 ] = temp;                   //找到位置後插入
    }
}

int main() {
    // Call the insertion sort function
    int i=0;
    for (; i < array_size; i=i+1) {
        // *((&(_test_start))+4) = ((&(array_addr)+2)); // Copy the sorted elements to the destination
        *((&(_test_start))+i) = *((&(array_addr))+i); // Copy the sorted elements to the destination
        // *((&(_test_start))) = *((&(array_addr))); // Copy the sorted elements to the destination
        // *((&(_test_start))+2) = *((&(array_addr))+i);
        // *((&(_test_start))+i) = *((&(array_addr))+i+1); // Copy the sorted elements to the destination
        // *((&(_test_start))+4*i+2) = *((&(array_addr))+4*i+2); // Copy the sorted elements to the destination
    }
    insertionSort();

    // Print the sorted array or perform further processing if needed

    return 0;
}


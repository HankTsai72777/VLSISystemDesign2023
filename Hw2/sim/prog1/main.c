int main(void){
    extern int _test_start, array_size, array_addr;

	int *output = &_test_start;
	int *array = &array_addr;


    int rem, i, j;
    for(i=1; i<array_size; i++) {
        rem = array[i];
        j = i - 1;
        
        while(j >= 0 && array[j] > rem) {
            array[j + 1] = array[j];
            j--;
        }
        array[j + 1] = rem;
    }
    
    for(i = 0; i < array_size; i++) {
        output[i] = array[i];
    }
    
    return 0;
}


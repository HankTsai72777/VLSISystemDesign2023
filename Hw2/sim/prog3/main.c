int main(void){
    extern unsigned int _test_start, div1, div2;
    
	int *output = &_test_start;
	
    while(div1!=0 && div2!=0){
        if(div1>div2){
            div1 -= div2;
        } 
        else{
            div2 -= div1;
        }
    }

    output[0] = (div1 == 0)? div2 : div1;

    return 0;
}

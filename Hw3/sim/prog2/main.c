///////////////////////////////////////////////
//             Grayscale                    //
///////////////////////////////////////////////
#include <stdint.h>
#include <stdio.h>
typedef unsigned char uint8_t; 
int main(void) {

    extern uint8_t _binary_image_bmp_start;
    extern uint8_t _binary_image_bmp_end;
    extern uint8_t __sdata_paddr_start;
    // extern int _binary_image_bmp_size;
    extern uint8_t _test_start;
    // uint8_t bmp_head = &_binary_image_bmp_start;

    // uint8_t gray =0 ;//the answer of grayscale
    unsigned int gray =0 ;//the answer of grayscale
    uint8_t size_1 = *(&_binary_image_bmp_start+2);
    uint8_t size_2 = *(&_binary_image_bmp_start+3);
    uint8_t size_3 = *(&_binary_image_bmp_start+4);
    uint8_t size_4 = *(&_binary_image_bmp_start+5);
    // int binary_image_bmp_size = a<<6+b<<4+c<<2+d;
    int binary_image_bmp_size = size_1+size_2*256+size_3*256*256+size_4*256*256*256;
    // binary_image_bmp_size = binary_image_bmp_size/;
    // number_of_group = _binary_image_bmp_size;
    // *((&(_test_start))+12340) = size_1; // Copy the sorted elements to the destination
    // *((&(_test_start))+12341) = size_2; // Copy the sorted elements to the destination
    // *((&(_test_start))+12342) = size_3; // Copy the sorted elements to the destination
    // *((&(_test_start))+12343) = size_4; // Copy the sorted elements to the destination
    // uint8_t *r = NULL ;
    // uint8_t *g = NULL ;
    // uint8_t *b = NULL ;
    // b = *(&_binary_image_bmp_start+110);
    // g = *(&_binary_image_bmp_start+110+1);
    // r = *(&_binary_image_bmp_start+110+2);
    uint8_t r ;
    uint8_t g ;
    uint8_t b ;
    // b = *(&_binary_image_bmp_start+175);
    // g = *(&_binary_image_bmp_start+177+1);
    // r = *(&_binary_image_bmp_start+177+2);
    // *((&(_test_start))+12340) = b; // Copy the sorted elements to the destination
    // *((&(_test_start))+12341) = g; // Copy the sorted elements to the destination
    // *((&(_test_start))+12342) = r; // Copy the sorted elements to the destination
    for(int i =0 ;i< 54; i=i+1){
        *((&(_test_start))+i) = *(&_binary_image_bmp_start+i); // Copy the sorted elements to the destination
    }
    for (int i =54 ;i< binary_image_bmp_size; i=i+3){
      // *((&(_binary_image_bmp_start))+i) = 1; // Copy the sorted elements to the destination
        //data_answer =0 ;
        b = *(&_binary_image_bmp_start+i);
        g = *(&_binary_image_bmp_start+i+1);
        r = *(&_binary_image_bmp_start+i+2);
        // gray = (0.11* r + 0.59*g + 0.3*b)  ;
        gray = (b * 11 + g*59 + r*30)  ;
        gray = gray/100;
        *((&(_test_start))+i) = gray;
        *((&(_test_start))+i+1) = gray;
        *((&(_test_start))+i+2) = gray;
        // gray =  (uint8_t)(0.11*blue[i*3] + 0.59*green[i*3] + 0.3*red[i*3])  ;
        // // result[counter] = gray;       
        // counter = counter +1;

    }

    return 0;
}
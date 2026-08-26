int main(void){
    unsigned int a=0xFF00FF00, b=0x00FF00FF;
    unsigned int c = (a & 0xFFFF0000) >> 16; /* 0xFF00 */
    unsigned int d = (b & 0x000000FF);       /* 0xFF */
    int e = (int)(c ^ d);                     /* 0xFF00 ^ 0xFF = 0xFFFF */
    return (e >> 8) - (e & 0xFF) + 42;       /* 0xFF - 0xFF + 42 = 42 */
}

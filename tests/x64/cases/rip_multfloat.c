/* Multiple float constants: several RIP-relative loads from .data */
int main(void){
    volatile double a = 10.0;
    volatile double b = 3.14159;
    volatile double c = 2.71828;
    int r;
    r = (int)(a * b + c); /* 10*3.14159+2.71828=34.1341... → 34 */
    return r + 8; /* 34+8=42 */
}

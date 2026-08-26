int main(void){
    unsigned char b = 200;
    short s = -100;
    int i = (int)b + (int)s; /* 200 + (-100) = 100 */
    unsigned int u = 0xFFFFFFFF;
    int neg = (int)u; /* -1 */
    return i + neg + 1 - 58; /* 100 + (-1) + 1 - 58 = 42 */
}

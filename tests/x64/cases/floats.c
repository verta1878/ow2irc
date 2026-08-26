int main(void){
    volatile double a = 10.5, b = 31.5;
    volatile double c = 6.0, d = 7.0;
    volatile double n = 84.0, dd = 2.0;
    int s = 0;
    s += (int)(a + b);    /* 42 */
    s += (int)(c * d);    /* 42 */
    s += (int)(n / dd);   /* 42 */
    s -= (int)(b - a);    /* -21 */
    return s - 63;        /* 42+42+42-21-63 = 42 */
}

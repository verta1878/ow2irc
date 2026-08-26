int counter(void){
    static int n = 0;
    n += 7;
    return n;
}
int main(void){
    int a, b, c, d, e, f;
    a = counter(); /* 7 */
    b = counter(); /* 14 */
    c = counter(); /* 21 */
    d = counter(); /* 28 */
    e = counter(); /* 35 */
    f = counter(); /* 42 */
    return f;
}

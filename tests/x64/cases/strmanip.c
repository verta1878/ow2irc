/* String manipulation without function-pointer-parameter passing */
int main(void){
    char buf[] = "hello world!";
    int i, n=0;
    for(i=0; buf[i]; i++) {
        if(buf[i]>='a' && buf[i]<='z') buf[i] -= 32;
        n++;
    }
    /* verify: buf is now "HELLO WORLD!", n=12 */
    return n + 30; /* 12+30=42 */
}

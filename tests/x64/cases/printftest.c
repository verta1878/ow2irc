extern int printf(const char *, ...);
int main(void){
    int a = 20, b = 22;
    printf("sum: %d\n", a + b);
    printf("%s has %d letters\n", "hello", 5);
    printf("neg: %d, hex: %x\n", -1, 255);
    return 42;
}

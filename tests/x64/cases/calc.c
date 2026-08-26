extern int printf(const char *, ...);
extern int puts(const char *);

int eval(int a, char op, int b){
    switch(op){
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/': return b != 0 ? a / b : 0;
        case '%': return b != 0 ? a % b : 0;
        case '&': return a & b;
        case '|': return a | b;
        case '^': return a ^ b;
    }
    return 0;
}

int main(void){
    printf("10 + 32 = %d\n", eval(10, '+', 32));
    printf("100 - 58 = %d\n", eval(100, '-', 58));
    printf("6 * 7 = %d\n", eval(6, '*', 7));
    printf("84 / 2 = %d\n", eval(84, '/', 2));
    printf("100 %% 58 = %d\n", eval(100, '%', 58));
    printf("0xFF & 0x2A = %d\n", eval(0xFF, '&', 0x2A));
    printf("0x20 | 0x0A = %d\n", eval(0x20, '|', 0x0A));
    printf("0x2A ^ 0x00 = %d\n", eval(0x3F, '^', 0x15));
    return eval(6, '*', 7);
}

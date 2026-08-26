typedef int (*op_func)(int, int);
int add(int a, int b){ return a+b; }
int sub(int a, int b){ return a-b; }
int mul(int a, int b){ return a*b; }

int apply(op_func f, int a, int b){ return f(a, b); }
int main(void){
    int r;
    r = apply(add, 10, 5);   /* 15 */
    r = apply(mul, r, 2);    /* 30 */
    r = apply(add, r, 12);   /* 42 */
    return r;
}

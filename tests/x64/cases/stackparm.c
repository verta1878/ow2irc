/* 5+ parameters: 5th arg passed on stack (pointer 1st forces 8-byte slot) */
extern int printf(const char *, ...);
int show(const char *name, int a, int b, int c, int d){
    printf("%s: a=%d b=%d c=%d d=%d\n", name, a, b, c, d);
    return a+b+c+d;
}
int six(int a,int b,int c,int d,int e,int f){ return a+b+c+d+e+f; }
int main(void){
    if( six(1,2,3,4,5,6) != 21 ) return 1;
    return show("test", 10, 20, 5, 7);   /* 42 */
}

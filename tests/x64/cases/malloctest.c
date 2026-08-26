extern int printf(const char *, ...);
extern void * __cdecl malloc(unsigned long);
int main(void){
    int *p;
    p = (int *)malloc(40);
    printf("ptr = %x\n", (unsigned int)p);
    p[0] = 42;
    printf("p[0] = %d\n", p[0]);
    return p[0];
}

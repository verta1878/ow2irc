int add(int a,int b){ return a+b; }
int apply(int (*f)(int,int), int a, int b){ return f(a,b); }
int main(void){ return apply(add,40,2); }

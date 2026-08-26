int add(int a,int b){ return a+b; }
int main(void){ int (*f)(int,int); f = add; return f(40,2); }

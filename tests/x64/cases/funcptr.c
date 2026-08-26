int apply(int (*f)(int), int x){ return f(x); }
int dbl(int x){ return x * 2; }
int main(void){ return apply(dbl, 21); }

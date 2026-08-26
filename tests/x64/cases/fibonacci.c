int fib(int n){ return n<=1 ? n : fib(n-1)+fib(n-2); }
int main(void){ return fib(10)-13; } /* fib(10)=55, 55-13=42 */

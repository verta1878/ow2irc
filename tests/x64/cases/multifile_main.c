extern int printf(const char *, ...);
int gcd(int, int);
int factorial(int);
int is_prime(int);
int main(void){
    int i, count=0;
    printf("gcd(48,18) = %d\n", gcd(48,18));
    printf("5! = %d\n", factorial(5));
    for(i=2;i<20;i++) if(is_prime(i)) count++;
    printf("primes < 20: %d\n", count);
    return factorial(5) - gcd(48,18)*13;
}

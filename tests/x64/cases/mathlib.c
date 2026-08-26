int gcd(int a, int b){
    while(b){ int t = b; b = a % b; a = t; }
    return a;
}
int factorial(int n){
    int r = 1, i;
    for(i=2; i<=n; i++) r *= i;
    return r;
}
int is_prime(int n){
    int i;
    if(n<2) return 0;
    for(i=2; i*i<=n; i++) if(n%i==0) return 0;
    return 1;
}

int fact(int n){ return n<=1 ? 1 : n*fact(n-1); }
int gcd(int a,int b){ while(b){ int t=a%b; a=b; b=t; } return a; }
int main(void){ return fact(5)/gcd(120,4) + 12; }

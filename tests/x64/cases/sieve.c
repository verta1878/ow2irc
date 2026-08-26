extern int printf(const char *, ...);
int main(void){
    char sieve[256];
    int i, j, count=0;
    for(i=0;i<256;i++) sieve[i]=1;
    sieve[0]=sieve[1]=0;
    for(i=2;i<16;i++){
        if(sieve[i]){
            for(j=i*i;j<256;j+=i) sieve[j]=0;
        }
    }
    for(i=0;i<256;i++) if(sieve[i]) count++;
    printf("primes below 256: %d\n", count);
    return count - 12; /* 54 primes below 256, 54-12=42 */
}

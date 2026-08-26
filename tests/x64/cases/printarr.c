extern int printf(const char *, ...);
int primes[] = {2,3,5,7,11,13,17,19,23,29};
int main(void){
    int i, sum=0;
    for(i=0;i<10;i++){
        printf("%d ", primes[i]);
        sum += primes[i];
    }
    printf("\nsum=%d\n", sum);
    return sum - 87; /* 129-87=42 */
}

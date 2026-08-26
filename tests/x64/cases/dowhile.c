int main(void){
    int n=1, sum=0;
    do { sum += n; n++; } while(n <= 9);
    return sum - 3; /* 45-3=42 */
}

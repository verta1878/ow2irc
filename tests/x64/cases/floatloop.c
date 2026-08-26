int main(void){
    volatile double sum = 0.0;
    int i;
    for(i = 1; i <= 7; i++) sum += (double)i;
    return (int)sum + 14;
}

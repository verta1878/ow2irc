double arr[4] = {10.0, 10.5, 10.5, 11.0};
int main(void){
    volatile double sum = 0.0;
    int i;
    for(i = 0; i < 4; i++) sum += arr[i];
    return (int)sum;
}

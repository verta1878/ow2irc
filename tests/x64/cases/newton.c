double my_sqrt(double x){
    double guess = x / 2.0;
    int i;
    for(i = 0; i < 20; i++)
        guess = (guess + x / guess) / 2.0;
    return guess;
}
int main(void){ return (int)(my_sqrt(1764.0)); }

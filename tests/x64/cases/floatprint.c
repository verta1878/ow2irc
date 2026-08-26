extern int printf(const char *, ...);
double my_sqrt(double x){
    double g = x / 2.0;
    int i;
    for(i=0;i<20;i++) g = (g + x/g) / 2.0;
    return g;
}
int main(void){
    int r = (int)my_sqrt(1764.0);
    printf("sqrt(1764) = %d\n", r);
    return r;
}

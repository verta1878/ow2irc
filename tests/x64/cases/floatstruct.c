struct point { double x, y; };
int main(void){
    volatile struct point p;
    p.x = 10.5; p.y = 31.5;
    return (int)(p.x + p.y);
}

int square(int x){ return x * x; }
int cube(int x){ return x * square(x); }
int main(void){ return cube(3) + square(2) - cube(1) + 12; }

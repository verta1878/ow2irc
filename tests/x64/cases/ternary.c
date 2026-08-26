int abs_val(int x){ return x < 0 ? -x : x; }
int max(int a, int b){ return a > b ? a : b; }
int main(void){ return max(abs_val(-20), abs_val(22)) + 20; }

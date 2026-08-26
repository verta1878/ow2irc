typedef enum { RED=1, GREEN=2, BLUE=4 } color_t;
int main(void){
    color_t c = RED | GREEN | BLUE;
    return (c == 7) ? 42 : 0;
}

struct P { int x, y; };
struct P g = { 20, 22 };
int main(void){ struct P *p = &g; return p->x + p->y; }

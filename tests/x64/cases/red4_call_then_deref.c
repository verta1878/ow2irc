extern int puts(const char*);
struct S { int a; int b; };
struct S s = { 40, 2 };
int main(void){ struct S *p; p = &s; puts("x"); return p->a + p->b; }

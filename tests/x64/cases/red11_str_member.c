extern int puts(const char*);
struct D { int id; const char *nm; };
struct D a = { 42, "hi" };
int main(void){ struct D *p; p = &a; puts(p->nm); return p->id; }

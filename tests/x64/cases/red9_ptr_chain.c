struct D { int id; struct D *next; };
struct D b = { 2, 0 };
struct D a = { 40, &b };
int main(void){ struct D *p; int s; s = 0;
  p = &a; while(p){ s += p->id; p = p->next; } return s; }

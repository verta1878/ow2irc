extern int puts(const char*);
struct Dev { int id; const char *name; struct Dev *next; };
struct Dev d3 = { 3, "dev3", 0 };
struct Dev d2 = { 2, "dev2", &d3 };
struct Dev d1 = { 1, "dev1", &d2 };
int main(void){ struct Dev *p = &d1; int sum = 0;
  while(p){ puts(p->name); sum += p->id; p = p->next; }
  return sum + 36; }

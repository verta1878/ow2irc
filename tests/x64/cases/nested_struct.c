struct In { int a, b; };
struct Out { struct In in; int c; };
struct Out tbl[3] = { {{1,2},3}, {{4,5},6}, {{7,8},9} };
int main(void){ int s=0,i; for(i=0;i<3;i++) s += tbl[i].in.a + tbl[i].in.b + tbl[i].c;
                return s + 3; }

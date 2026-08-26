char src[] = "hello world";
char dst[32];
int mystrlen(const char*s){ int n=0; while(*s++) n++; return n; }
void mystrcpy(char*d,const char*s){ while((*d++=*s++)); }
int main(void){ mystrcpy(dst,src); return mystrlen(dst)+31; }

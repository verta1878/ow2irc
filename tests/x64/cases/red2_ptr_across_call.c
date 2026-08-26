extern int puts(const char*);
int g = 42;
int main(void){ int *p; p = &g; puts("x"); return *p; }

union U { int i; unsigned char b[4]; };
int main(void){ union U u; u.i = 0; u.b[0]=42; return u.b[0]; }

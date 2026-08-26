static int st = 10;
int bump(void){ st++; return st; }
int main(void){ bump(); bump(); return st + 30; }

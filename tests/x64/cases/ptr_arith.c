int buf[8];
int main(void){ int *p; int i; int s;
  p = buf; for(i=0;i<8;i++) *p++ = i;
  p = buf; s = 0; for(i=0;i<8;i++) s += *p++;
  return s + 14; }

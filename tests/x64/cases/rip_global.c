/* RIP-relative: global var accessed via mov 0x0(%rip),%reg */
int secret = 42;
int hidden = 100;
int main(void){ return secret + hidden - 100; }

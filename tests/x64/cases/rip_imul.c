/* RIP-relative IMUL: global * constant via imul $imm8, disp(%rip), %reg */
int scale = 7;
int multiplier = 6;
int main(void){ return scale * multiplier; }

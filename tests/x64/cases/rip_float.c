/* RIP-relative: float constant loaded via fmull 0x0(%rip) */
double half(double x){ return x * 0.5; }
double third(double x){ return x / 3.0; }
int main(void){
    return (int)(half(84.0)) + (int)(third(84.0) - 28.0);
    /* half(84)=42.0, third(84)=28.0, 28-28=0, 42+0=42 */
}

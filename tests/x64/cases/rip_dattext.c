/* Data-in-text: initialized local array data in .text segment */
int main(void){
    int lookup[] = {10, 20, 30, 40, 50, 60, 70};
    int i, sum=0;
    for(i=0;i<7;i++) sum += lookup[i];
    return sum - 238; /* 10+20+30+40+50+60+70=280, 280-238=42 */
}

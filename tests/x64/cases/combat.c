/* Combat simulation: tests IMUL RIP-relative, global vars, multi-function */
int hp, gold, level;
int fight(int mhp, int matk, int mgold){
    int rounds = 0;
    while(hp > 0 && mhp > 0){
        mhp -= level * 10;
        if(mhp > 0) hp -= matk;
        rounds++;
    }
    if(hp > 0){ gold += mgold; return rounds; }
    return 0;
}
int main(void){
    hp = 100; gold = 0; level = 1;
    fight(30, 5, 10);  /* goblin: 3 rounds, hp=90, gold=10 */
    level = 2;
    fight(80, 15, 25); /* orc: 4 rounds, hp=45, gold=35 */
    return gold + 7;   /* 35+7=42 */
}

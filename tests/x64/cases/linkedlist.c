struct node { int val; int next; }; /* next=-1 for end */
int main(void){
    struct node list[5];
    int i, sum=0, cur;
    list[0].val=10; list[0].next=1;
    list[1].val=8;  list[1].next=2;
    list[2].val=6;  list[2].next=3;
    list[3].val=4;  list[3].next=4;
    list[4].val=2;  list[4].next=-1;
    for(cur=0; cur>=0; cur=list[cur].next) sum+=list[cur].val;
    return sum+12; /* 10+8+6+4+2=30, 30+12=42 */
}

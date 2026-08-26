int main(void){
    int i, j, count=0;
    for(i=0; i<10; i++){
        if(i==3) continue;
        for(j=0; j<10; j++){
            if(j==7) break;
            if((i+j)%3==0) count++;
        }
    }
    return count + 21; /* 21+21=42 */ /* should be 21... let me compute */
}

int main(void){
    int m[9]; /* 3x3 matrix stored flat */
    int i, trace;
    for(i=0;i<9;i++) m[i] = i+1; /* 1..9 */
    trace = m[0] + m[4] + m[8]; /* 1+5+9=15 */
    return trace + 27; /* 15+27=42 */
}

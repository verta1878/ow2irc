/* Register-relative: array[i] via [reg + abs_addr] with R_X86_64_32S */
int weights[8] = {1,2,3,4,5,6,7,8};
int main(void){
    int i, wsum=0;
    for(i=0;i<8;i++) wsum += weights[i] * (i+1);
    return wsum - 162; /* 1+4+9+16+25+36+49+64=204, 204-162=42 */
}

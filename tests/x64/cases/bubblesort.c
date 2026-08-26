int main(void){
    int arr[] = {5,3,8,1,9,2,7,4,6,0};
    int i, j, tmp, n=10;
    for(i=0; i<n-1; i++)
        for(j=0; j<n-i-1; j++)
            if(arr[j]>arr[j+1]){ tmp=arr[j]; arr[j]=arr[j+1]; arr[j+1]=tmp; }
    /* sorted: 0,1,2,3,4,5,6,7,8,9 → arr[4]=4, arr[5]=5 → 4*5+22=42 */
    return arr[4]*arr[5]+22;
}

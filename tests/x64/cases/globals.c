int counter = 40;
int get(void){ return counter; }
int main(void){ counter = counter + 2; return get(); }

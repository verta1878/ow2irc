/* Immediate address: mov $string_addr,%eax with R_X86_64_32S */
extern int puts(const char *);
char msg1[] = "rip-relative";
char msg2[] = "test passed";
int main(void){
    puts(msg1);
    puts(msg2);
    return 42;
}

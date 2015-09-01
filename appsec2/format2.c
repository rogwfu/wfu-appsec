#undef _FORTIFY_SOURCE
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int target;

void be_nice_to_people() {
    // /bin/sh is usually symlinked to bash, which usually drops privs. Make
    // sure we don't drop privs if we exec bash, (ie if we call system()).
    gid_t gid = getegid();
    setresgid(gid, gid, gid);
}

void printbuffer(char *string)
{
        printf(string);
}

void vuln(char *formatStr)
{
        printbuffer(formatStr);

        if(target == 0x01025544) {
                printf("you have modified the target :)\n");
				printf("running sh...\n");
				system("/bin/sh");
        } else {
                printf("target is %08x :(\n", target);
        }
}

int main(int argc, const char **argv) {
    be_nice_to_people();
    char buf[100];

  if(argc == 1) {
    errx(1, "please specify an argument\n");
  }

    memset(buf, '\0', sizeof(buf));
    memcpy(buf, argv[1], sizeof(buf)); 

    vuln(buf);
}

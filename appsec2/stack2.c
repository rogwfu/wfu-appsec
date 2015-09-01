#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void be_nice_to_people() {
    // /bin/sh is usually symlinked to bash, which usually drops privs. Make
    // sure we don't drop privs if we exec bash, (ie if we call system()).
    gid_t gid = getegid();
    setresgid(gid, gid, gid);
}

int main(int argc, char **argv)
{
  volatile int modified;
  char buffer[64];

  if(argc == 1) {
    errx(1, "please specify an argument\n");
  }

  be_nice_to_people();

  modified = 0;
  strcpy(buffer, argv[1]);

  if(modified == 0x61626364) {
    printf("you have correctly got the variable to the right value.  Spawning a shell...\n");
    system("/bin/sh");
  } else {
    printf("Try again, you got 0x%08x\n", modified);
  }
}
/* Reference: http://exploit-exercises.com/protostar/stack1 */ 

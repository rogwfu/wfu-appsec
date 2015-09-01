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

int spawnShell()
{
    printf("\nrunning sh...\n");
    system("/bin/sh");
	return(1);
}

void vuln_func(char *str)
{
  char buffer[64];
  strcpy(buffer, str);
  printf("Buffer: %s\n", buffer);

}

int main(int argc, char **argv)
{
  be_nice_to_people();

  if(argc == 1) {
    errx(1, "please specify an argument\n");
  }

  vuln_func(argv[1]);
}

# Set the shell
SHELL := /bin/zsh

# Replace .c for .rtf and make the files
all:
    @for i in `ls *.c` ; do make $$i:r ; done

# Pattern rule to compile files
%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -f *.o

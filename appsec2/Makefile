# Set the shell
SHELL := /bin/zsh

# Replace .c for .rtf and make the files
all: 
	@for i in `ls *.c` ; do make $$i:r.rtf ; done 

# Implicit rule to pygmentize files
%.rtf: %.c
	pygmentize -o $@ $< 

# Cleanup all the rtf files generated
.PHONY: clean
clean:
	rm *.rtf

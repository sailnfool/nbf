SHELL=/bin/bash
PREFIX?=$(HOME)
LPREFIX?=$(HOME)/.local
TMPDIR=/tmp/tmpgit$$
GITUSER=sailnfool
GITREPO=bf
GITBRANCH=main
GITDIR=tests
.sh.pass:
	@rm -f $@
	rm -f $<
	dotestssingle $< $@
	wget https://raw.githubusercontent.com/$(GITUSER)/$(GITREPO)/$(GITBRANCH)/$(GITDIR)/$<
	cp $< $@
LINSTALL =	bf.insufficient \
		bf.kbytes \
		bf.nice2num \
		bf.os \
		bf.regex \
		bf.toseconds \
		bf.ansi_colors \
		bf.seed_random \

EXECDIR := $(PREFIX)/bin
LEXECDIR := $(LPREFIX)/bin

LTEST = tester.bf.bashseedrandom.sh \
	tester.bf.createorthodox.sh \
	tester.bf.gethash.sh \
	tester.bf.hex2dec.sh \
	tester.bf.kbytes.sh \
	tester.bf.keyvalueload.sh \
	tester.bf.nice2num.sh \
	tester.bf.num2nice.sh \
	tester.bf.os.sh \
	tester.bf.regex.sh \
	tester.bf.split.sh \
	tester.bf.stripquotes.sh \
	tester.bf.toseconds.sh \
	tester.bf.validip.sh \
	tester.something.sh 

test: tester.*.sh
	dotests tester.*.sh

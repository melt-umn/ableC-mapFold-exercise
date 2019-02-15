
# Path from current directory to top level ableC repository
ABLEC_BASE?=../../../ableC
# Path from current directory to top level extensions directory
EXTS_BASE?=../../../extensions

# All directories containing grammars that may be included
GRAMMAR_DIRS=$(ABLEC_BASE)/grammars $(wildcard $(EXTS_BASE)/*/grammars) ../grammars artifact

# All silver files in included grammars, to be included as dependancies
GRAMMAR_SOURCES=$(shell find $(GRAMMAR_DIRS) -name *.sv -print0 | xargs -0)
# Flags passed to silver including the appropriate directories
override SVFLAGS+=$(addprefix -I ,$(GRAMMAR_DIRS))

all: map_fold.out

ableC.jar: $(GRAMMAR_SOURCES)
	touch artifact/Artifact.sv
	silver-ableC -o $@ $(SVFLAGS) artifact

map_fold.c:	map_fold.xc ableC.jar
	java -Xss6M -jar ableC.jar map_fold.xc

map_fold.o:	map_fold.c
	gcc -std=gnu11 -c map_fold.c

map_fold.out:	map_fold.o
	gcc -o map_fold.out map_fold.o

clean:
	rm -f *~ *.i *.c *.o *.out *.test *.jar *.copperdump.html build.xml

.PHONY: all clean

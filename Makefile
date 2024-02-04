CC      ?= gcc
CFLAGS  ?= -O2 -Wall -Wextra -Wno-missing-field-initializers -Wno-unused-parameter -Wno-format-truncation -g2
LDFLAGS ?= -lrt

.DEFAULT_GOAL := all

.PHONY: all clean

all: flashbench erase

dev.o: dev.c dev.h
vm.o: vm.c vm.h dev.h
flashbench.o: flashbench.c vm.h dev.h

flashbench: flashbench.o dev.o vm.o
#	$(CC) $(LDFLAGS) -o $@ $^
erase: erase.o

clean:
	rm -f flashbench flashbench.o dev.o vm.o erase erase.o

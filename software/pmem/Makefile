KDIR		:= /lib/modules/$(shell uname -r)/build/
PWD		:= $(shell pwd)

obj-m		:= pmem.o

all:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) V=1 modules
	gcc -O -Wall -o wr wr.c
	gcc -O -Wall -o rd rd.c

clean:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) clean 
	rm -f wr rd

all:
	make -C src/ -f Makefile all

test:
	make -C src/ -f Makefile test

clean:
	make -C src/ -f Makefile clean


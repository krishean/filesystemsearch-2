
all:
	+$(MAKE) -C src

strip: all
	+$(MAKE) -C src $@

clean:
	+$(MAKE) -C src $@

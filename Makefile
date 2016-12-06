
all: theories/Makefile libraries/Makefile
	$(MAKE) -C libraries
#	$(MAKE) -C libraries/SquiggleEq
	$(MAKE) -C theories
	

theories/Makefile:
	cd theories;coq_makefile -f _CoqProject -o Makefile

libraries/Makefile:
	cd libraries;coq_makefile -f _CoqProject -o Makefile

clean:
	$(MAKE) clean -C libraries
#	$(MAKE) clean -C libraries/SquiggleEq
	$(MAKE) clean -C theories

cleanCoqc:
	find -name *.vo | xargs rm
	find -name *.glob | xargs rm
	find -name *.v.d | xargs rm
	
gitsuperclean:
	git reset HEAD --hard
	git clean -xf

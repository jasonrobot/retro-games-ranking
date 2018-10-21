LISP=sbcl
RM=rm -f

LISP_FLAGS := --noinform --non-interactive
LISP_BUILD := "(progn (require :retro-games) (asdf:make :retro-games))"
LISP_TEST := "(progn (require :retro-games-test) (asdf:test-system 'retro-games))"

retro-games: *.lisp *.asd
	$(LISP) $(LISP_FLAGS) --eval $(LISP_BUILD)

test:
	$(LISP) $(LISP_FLAGS) --eval $(LISP_TEST)

clean:
	$(RM) retro-games

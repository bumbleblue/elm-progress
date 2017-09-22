EXAMPLES := $(wildcard *.elm)
TARGETS := $(addprefix build/,$(EXAMPLES:.elm=.html)) build/Visual.js

INCLUDE_FILES := $(wildcard ../*.elm) $(wildcard ../lib/elm-usermedia/src/*.elm)
SCRIPTS := $(wildcard ../Native/*.js) $(wildcard ../lib/elm-usermedia/src/Native/*.js)

.PHONY: all
all: $(TARGETS)

$(TARGETS): $(INCLUDE_FILES) $(SCRIPTS)

build/%.js: %.elm
	elm-make --yes $(CURDIR)/$< --output $(CURDIR)/$@

build/%.html: %.elm
	elm-make --yes $(CURDIR)/$< --output $(CURDIR)/$@
	@echo "** Open $@ in your browser"

-include .config.mk

PKG = orgit-forge

ELS   = $(PKG).el
ELCS  = $(ELS:.el=.elc)

DEPS  = closql
DEPS += compat
DEPS += cond-let
DEPS += emacsql
DEPS += forge/lisp
DEPS += ghub/lisp
DEPS += llama
DEPS += magit/lisp
DEPS += markdown-mode
DEPS += org/lisp
DEPS += orgit
DEPS += transient/lisp
DEPS += treepy
DEPS += with-editor/lisp
DEPS += yaml

EMACS      ?= emacs
EMACS_ARGS ?=

LOAD_PATH  ?= $(addprefix -L ../,$(DEPS))
LOAD_PATH  += -L .

all: lisp

help:
	$(info make all          - generate byte-code and autoloads)
	$(info make lisp         - generate byte-code and autoloads)
	$(info make redo         - re-generate byte-code and autoloads)
	$(info make clean        - remove generated files)
	@printf "\n"

redo: clean lisp

lisp: $(ELCS) loaddefs check-declare

loaddefs: $(PKG)-autoloads.el

%.elc: %.el
	@printf "Compiling $<\n"
	@$(EMACS) -Q --batch $(EMACS_ARGS) $(LOAD_PATH) -f batch-byte-compile $<

check-declare:
	@printf " Checking function declarations\n"
	@$(EMACS) -Q --batch $(EMACS_ARGS) $(LOAD_PATH) \
	--eval "(check-declare-directory default-directory)"

CLEAN  = $(ELCS) $(PKG)-autoloads.el

clean:
	@printf " Cleaning...\n"
	@rm -rf $(CLEAN)

$(PKG)-autoloads.el: $(ELS)
	@printf " Creating $@\n"
	@$(EMACS) -Q --batch --eval "\
(let ((inhibit-message t))\
  (loaddefs-generate\
   default-directory \"$@\" nil\
   (prin1-to-string\
    '(add-to-list 'load-path\
                  (or (and #$$ (directory-file-name (file-name-directory #$$)))\
                      (car load-path)))))\
   nil t)"

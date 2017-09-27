.PHONY: all dots test shellcheck

all: dots test

dots: export RCRC=$(HOME)/.dotfiles/config/rcrc
dots:
	rcup -v

test: shellcheck



# if this session isn't interactive, then we don't want to allocate a
# # TTY, which would fail, but if it is interactive, we do want to attach
# # so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		--entrypoint="/bin/bash"
		kyleondy/shellcheck ./test.sh
TARGETS := $(shell ls scripts | grep -vE '(webserver|build-packages|clean)')

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m|sed 's/v7l//'` > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	./.dapper $@

build-packages: .dapper stopweb webserver
	./.dapper -m bind build-packages 2>&1 | tee  dist/build-packages.log
	docker rm -f strato-server || true

webserver:
	./scripts/webserver

stopweb:
	docker rm -f strato-server || true

strato: build-bin

.DEFAULT_GOAL := default

.PHONY: $(TARGETS)

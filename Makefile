all: build

start:
	@./start.sh

build:
	@./build.sh

.PHONY := start build

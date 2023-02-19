all: build

build:
	rm -rf assets
	rm -rf quickstart
	rm -rf reference
	rm -rf search
	mv site/* .
	rm -rf site

.PHONY := start build

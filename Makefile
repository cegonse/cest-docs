all: build

start:
	docker build --target serve -t cest-docs .
	xdg-open http://localhost:8000
	docker run --rm --publish 8000:8000 --name cest-docs --mount type=bind,source=$(shell pwd),target='/material' cest-docs

build:
	docker build --target build -t cest-docs .
	docker run --rm --name cest-docs --mount type=bind,source=$(shell pwd),target='/material' cest-docs

.PHONY := all build start

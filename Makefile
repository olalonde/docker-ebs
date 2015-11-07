.PHONY: build run test

build:
	docker build -t olalond3/ebs .
run:
	docker run --rm -it olalond3/ebs /bin/bash

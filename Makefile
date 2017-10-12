
IMAGE_NAME = buildout-centos7

.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .

IMAGE := overlydev/oracle-nabber
CONTEXT := $(shell pwd)/docker/_context
TEST_DIR := $(shell pwd)/docker/test
STORAGE_DIR := $(shell pwd)/docker/storage

build:
	mkdir -p $(CONTEXT)
	cp docker/Dockerfile $(CONTEXT)/.
	cp scripts/*.sh $(CONTEXT)/.
	cd docker/_context; DOCKER_BUILDKIT=0 docker build -t $(IMAGE) -f Dockerfile .

test: build
	mkdir -p $(TEST_DIR)
	cp .env $(TEST_DIR)/.
	cp *.pem $(TEST_DIR)/.
	cp *.pub $(TEST_DIR)/.
	cd docker; docker run --rm -it -v "$(TEST_DIR):/storage" -u $(shell id -u):$(shell id -g) $(IMAGE)

up: build
	mkdir -p docker/storage
	cp *.pem $(STORAGE_DIR)/.
	cp *.pub $(STORAGE_DIR)/.
	cd docker; docker-compose up -d

down:
	cd docker; docker-compose down

clean: down
	rm -rf $(CONTEXT) $(TEST_DIR) $(STORAGE_DIR)
	yes | docker container prune
	yes | docker image prune

.PHONY: build test up down clean
# safeish way of finding the folder that contains this Makefile
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# we use the builder variable here both as a folder path and docker image name.. split if needed
BUILDER=jekyll-builder

# a folder to handle dependency building of docker images (kind of)
STAMP_DIR=$(BUILDER)/stamps

.PHONY: serve
serve: $(BUILDER)
	docker run --platform linux/amd64 --rm -it \
               --volume="$(ROOT_DIR):/source" \
               --volume="$(ROOT_DIR)/_config.yml:/work/_config.yml" \
               --env JEKYLL_ENV=development -p 4000:4000 \
               $(BUILDER) serve

.PHONY: builder-debug
builder-debug: $(BUILDER)
	docker run --platform linux/amd64 --rm -it \
               --volume="$(ROOT_DIR)/_config.yml:/work/_config.yml" \
               --env JEKYLL_ENV=development \
               --entrypoint /bin/bash \
               $(BUILDER)



$(BUILDER): $(STAMP_DIR)/$(BUILDER)

$(STAMP_DIR)/$(BUILDER): $(BUILDER)/Dockerfile
	cd $(BUILDER) && docker build -t $(BUILDER) .
	touch $(STAMP_DIR)/$(BUILDER)

clean:
	rm $(STAMP_DIR)/*

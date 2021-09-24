# safeish way of finding the folder that contains this Makefile
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# we use the builder variable here both as a folder path and docker image name.. split if needed
BUILDER=jekyll-builder-local

# a folder to handle dependency building of docker images (kind of)
STAMP_DIR=$(BUILDER)/stamps

.PHONY: clean serve

serve: $(BUILDER)
	docker run --rm --volume="$(ROOT_DIR):/srv/jekyll" \
               --volume="$(ROOT_DIR)/vendor/bundle:/usr/local/bundle" \
               --env JEKYLL_ENV=development -p 4000:4000 \
               $(BUILDER) jekyll serve

$(BUILDER): $(STAMP_DIR)/$(BUILDER)

$(STAMP_DIR)/$(BUILDER): $(BUILDER)/Dockerfile
	cd $(BUILDER) && docker build -t $(BUILDER) .
	touch $(STAMP_DIR)/$(BUILDER)

clean:
	rm $(STAMP_DIR)/*

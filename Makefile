ALLEGRO_VERSION=4.4.3.1
ZLIB_VERSION=1.3.1
LIBPNG_VERSION=1.6.40
FREETYPE_VERSION=2.12.1
LIBOGG_VERSION=1.3.5
LIBVORBIS_VERSION=1.3.7
FLAC_VERSION=1.3.4
PHYSFS_VERSION=3.0.2

SUFFIX=-mingw-w64-i686

DOCKERHUB_USERNAME=hldtux
TAG_NAME=allegro-compiler:${ALLEGRO_VERSION}${SUFFIX}

.PHONY: build
build:
	docker build . \
	--build-arg ALLEGRO_VERSION=${ALLEGRO_VERSION} \
	--build-arg ZLIB_VERSION=${ZLIB_VERSION} \
	--build-arg LIBPNG_VERSION=${LIBPNG_VERSION} \
	--build-arg FREETYPE_VERSION=${FREETYPE_VERSION} \
	--build-arg LIBOGG_VERSION=${LIBOGG_VERSION} \
	--build-arg LIBVORBIS_VERSION=${LIBVORBIS_VERSION} \
	--build-arg FLAC_VERSION=${FLAC_VERSION} \
	--build-arg PHYSFS_VERSION=${PHYSFS_VERSION} \
	-t ${TAG_NAME}

build-linux:
	DOCKER_DEFAULT_PLATFORM=linux/amd64 $(MAKE) build

tag:
	docker tag ${TAG_NAME} ${DOCKERHUB_USERNAME}/${TAG_NAME}

login:
	docker login -u ${DOCKERHUB_USERNAME}

push: 	tag
	docker push ${DOCKERHUB_USERNAME}/${TAG_NAME}

shell:	build
	docker run -v $(shell pwd):/tmp/workdir -w /tmp/workdir \
	-ti ${TAG_NAME} \
	bash

clean:
	docker ps -f name=${TAG_NAME} -qa | xargs docker rm -f
	docker image ls --filter 'reference=${TAG_NAME}' -qa | xargs docker rmi -f

format:
	shfmt -w fn.sh
FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y install \
	wget \
	git \
	xz-utils \
	&& apt clean && rm -rf /var/lib/apt/lists/*

RUN useradd -U -G sudo -p '' -m builder && \
	mkdir -p /opt/source && \
	chown builder /opt/source/

# Fetch everything in /opt/sources
ARG ALLEGRO_VERSION=5.2.8.0
ARG ZLIB_VERSION=1.3
ARG LIBPNG_VERSION=1.6.40
ARG FREETYPE_VERSION=2.12.1
ARG LIBOGG_VERSION=1.3.5
ARG LIBVORBIS_VERSION=1.3.7
ARG FLAC_VERSION=1.3.4
ARG PHYSFS_VERSION=3.0.2
USER builder
WORKDIR /opt/source
RUN wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz -O- | tar xfz -
RUN wget http://downloads.sourceforge.net/project/libpng/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.gz -O- | tar xfz -
RUN wget http://downloads.sourceforge.net/project/freetype/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz -O- | tar xfz -
RUN wget https://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz -O- | tar xfz -
RUN wget https://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz -O- | tar xfz -
RUN git clone https://github.com/kode54/dumb.git --depth 1 && rm -rf dumb/.git
RUN wget https://ftp.osuosl.org/pub/xiph/releases/flac/flac-${FLAC_VERSION}.tar.xz -O- | tar xfJ -
RUN git clone https://github.com/lieff/minimp3.git --depth 1 && rm -rf minimp3/.git
RUN wget https://github.com/icculus/physfs/archive/refs/tags/release-${PHYSFS_VERSION}.tar.gz -O- | tar xfz -
RUN git clone https://github.com/liballeg/allegro5.git --branch $ALLEGRO_VERSION --depth 1 && rm -rf allegro5/.git

# All downloads complete. Start second stage.
FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ARG ALLEGRO_VERSION=5.2.8.0

RUN useradd -U -G sudo -p '' -m builder && \
	apt update && apt -y install \
	pkg-config \
	cmake \
	sudo \
	patch \
	# To save space, we only install the 32-bit i686 packages
	# This saves ~500s Mbs in the final docker image.
	# Alternatively, get mingw-w64 (both 32-bit and 64-bit)
	# or choose the -x86-64 or -i686 packages
	gcc-mingw-w64-i686 \
	g++-mingw-w64-i686 \
    make \
    sudo \
	&& apt clean && rm -rf /var/lib/apt/lists/*

COPY --from=0 /opt/ /opt/

USER builder

#COPY commit-d25c4cf.patch scripts/* /opt/source/
ADD fn.sh /opt/source/fn.sh

# bash as default
SHELL ["/bin/bash", "-c"]

RUN source /opt/source/fn.sh && \
 build_zlib && \
 build_png && \
 build_freetype && \
 build_ogg && \
 build_vorbis && \
 build_dumb && \
 install_minimp3 && \
 build_flac && \
 build_physfs

# COPY scripts/build-theora.sh /opt/source/

# # TODO: script broken still...
# # Theora - for video support
# # RUN ./build-theora.sh

# # TODO: 
# # FreeImage, webp - for webp support
# # Opus
# # physFS

RUN source /opt/source/fn.sh && \
    cd /opt/source/allegro5 && \
	#patch -p1 < /opt/source/commit-d25c4cf.patch && \
	build_alleg5_mingw_monolith && \
	build_alleg5_mingw_release && \
	build_alleg5_mingw_debug && \
	build_alleg5_mingw_debug_monolith && \
	build_alleg5_mingw_static && \
	rm -rf /opt/source/allegro5/Build

VOLUME /data
WORKDIR /data

# This is where pkg-config will find .pc files for allegro and other deps.
ENV PKG_CONFIG_LIBDIR=/usr/i686-w64-mingw32/lib/pkgconfig

CMD /bin/bash
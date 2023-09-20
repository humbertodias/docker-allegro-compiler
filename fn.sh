#!/bin/bash

build_zlib() {
	# Adapted from openTTD cross-compilation instructions (changed '/usr/local' to '/usr'):
	# https://wiki.openttd.org/en/Archive/Compilation and Ports/Cross-compiling for Windows
	cd /opt/source/zlib*
	# zlib 'configure' script is currently broken, use win32/Makefile.gcc directly
	sed -e s/"PREFIX ="/"PREFIX = i686-w64-mingw32-"/ -i win32/Makefile.gcc # automatic replacement
	make -f win32/Makefile.gcc
	sudo BINARY_PATH=/usr/i686-w64-mingw32/bin \
		INCLUDE_PATH=/usr/i686-w64-mingw32/include \
		LIBRARY_PATH=/usr/i686-w64-mingw32/lib \
		make -f win32/Makefile.gcc install
}

build_png() {
	# Adapted from openTTD cross-compilation instructions (updated version, changed '/usr/local' to '/usr'):
	# https://wiki.openttd.org/en/Archive/Compilation and Ports/Cross-compiling for Windows
	cd /opt/source/l*png*
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib"
	make
	sudo make install
	make clean
}

build_freetype() {
	# Adapted from openTTD cross-compilation instructions (just changed '/usr/local' to '/usr', and bumped version from 2.8 to 2.10):
	# https://wiki.openttd.org/en/Archive/Compilation and Ports/Cross-compiling for Windows
	cd /opt/source/freetype*
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		--enable-static \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib" \
		PKG_CONFIG_LIBDIR=/usr/i686-w64-mingw32/lib/pkgconfig
	make
	sudo make install
	make clean
	# Now freetype will be installed in /usr/i686-w64-mingw32
}

build_ogg() {
	cd /opt/source/libogg*
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib"
	make
	sudo make install
	make clean
}

build_vorbis() {
	cd /opt/source/libvorbis*
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib"
	make
	sudo make install
	make clean
}

build_dumb() {
	# git clone https://github.com/kode54/dumb.git --depth 1
	# Alternative for specific version:
	# wget https://github.com/kode54/dumb/archive/refs/tags/2.0.3.tar.gz -O- | tar xfz -

	cd /opt/source/dumb*
	mkdir -p build/release
	cd build/release
	cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DCMAKE_TOOLCHAIN_FILE=/opt/source/Toolchain-mingw.cmake \
		-DCMAKE_INSTALL_PREFIX=/usr/i686-w64-mingw32 \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DBUILD_EXAMPLES:BOOL=OFF \
		-DBUILD_ALLEGRO4:BOOL=OFF \
		../..
	make
	sudo make install
	sudo ldconfig
	cd ../..
	rm -r build
}
install_minimp3() {
	export INSTALL_PREFIX=/usr/i686-w64-mingw32

	cd /opt/source/minimp3
	sudo mkdir -p $INSTALL_PREFIX/include
	sudo cp minimp3*.h $INSTALL_PREFIX/include
	# That's it... minimp3 is header-only
}

build_flac() {
	cd /opt/source/flac*
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib"
	make
	sudo make install
	# TODO clean
}

build_physfs() {
	cd /opt/source/physfs*

	mkdir -p build/release
	cd build/release

	cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DCMAKE_TOOLCHAIN_FILE=/opt/source/Toolchain-mingw.cmake \
		-DCMAKE_INSTALL_PREFIX=/usr/i686-w64-mingw32 \
		../..

	make
	sudo make install
	sudo ldconfig
	cd ../..
	rm -r build/release
}

build_alleg5_mingw_monolith() {

	# Check that we're in the right place
	test -e src/allegro.c || (
		echo "Not correct allegro folder"
		exit 1
	)

	mkdir -p Build/MingwMonolith
	cd Build/MingwMonolith
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=../../cmake/Toolchain-mingw.cmake \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DWANT_MONOLITH=on \
		-DFREETYPE_PNG=on \
		-DFREETYPE_ZLIB=on \
		-DWANT_DEMO=off -DWANT_EXAMPLES=off -DWANT_DOCS=off \
		../..
	make
	sudo make install
	sudo ldconfig
	cd ../..
}

build_alleg5_mingw_release() {
	# Check that we're in the right place
	test -e src/allegro.c || (
		echo "Not correct allegro folder"
		exit 1
	)

	mkdir -p Build/MingwRelease
	cd Build/MingwRelease
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=../../cmake/Toolchain-mingw.cmake \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DFREETYPE_PNG=on \
		-DFREETYPE_ZLIB=on \
		-DWANT_DEMO=off -DWANT_EXAMPLES=off -DWANT_DOCS=off \
		../..
	make
	sudo make install
	sudo ldconfig
	cd ../..

}

build_alleg5_mingw_debug() {
	# Check that we're in the right place
	test -e src/allegro.c || (
		echo "Not correct allegro folder"
		exit 1
	)

	mkdir -p Build/MingwDebug
	cd Build/MingwDebug
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=../../cmake/Toolchain-mingw.cmake \
		-DCMAKE_BUILD_TYPE=Debug \
		-DFREETYPE_PNG=on \
		-DFREETYPE_ZLIB=on \
		-DWANT_DEMO=off -DWANT_EXAMPLES=off -DWANT_DOCS=off \
		../..
	make
	sudo make install
	sudo ldconfig
	cd ../..
}

build_alleg5_mingw_debug_monolith() {
	# Check that we're in the right place
	test -e src/allegro.c || (
		echo "Not correct allegro folder"
		exit 1
	)

	mkdir -p Build/MingwMonolithDebug
	cd Build/MingwMonolithDebug
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=../../cmake/Toolchain-mingw.cmake \
		-DCMAKE_BUILD_TYPE=Debug \
		-DWANT_MONOLITH=on \
		-DFREETYPE_PNG=on \
		-DFREETYPE_ZLIB=on \
		-DWANT_DEMO=off -DWANT_EXAMPLES=off -DWANT_DOCS=off \
		../..
	make
	sudo make install
	sudo ldconfig
	cd ../..
}

build_alleg5_mingw_static() {
	# Check that we're in the right place
	test -e src/allegro.c || (
		echo "Not correct allegro folder"
		exit 1
	)

	mkdir -p Build/MingwStatic
	cd Build/MingwStatic

	# Added CMAKE_SHARED_LINKER_FLAGS to prevent multiple definition error, see discussion here;
	# https://www.allegro.cc/forums/thread/618386/1049706#target
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=../../cmake/Toolchain-mingw.cmake \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DWANT_STATIC_RUNTIME=on \
		-DFREETYPE_PNG=on \
		-DFREETYPE_ZLIB=on \
		-DWANT_DEMO=off -DWANT_EXAMPLES=off -DWANT_DOCS=off \
		-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-allow-multiple-definition \
		../..
	make
	sudo make install
	sudo ldconfig
	cd ../..
}

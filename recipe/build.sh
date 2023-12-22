#!/bin/bash
set -ex

# Get an updated config.sub and config.guess
# Running autoreconf messes up the build so just copy these two files
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    export BUILD_CC=${CC_FOR_BUILD}
fi

if [[ $target_platform =~ osx-.* ]]; then
    export cf_cv_mixedcase=no
fi

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig

sh ./configure \
    --prefix=$PREFIX \
    --without-debug \
    --without-ada \
    --without-manpages \
    --with-shared \
    --with-pkg-config \
    --with-pkg-config-libdir="${PKG_CONFIG_LIBDIR}" \
    --disable-overwrite \
    --enable-symlinks \
    --enable-termcap \
    --enable-pc-files \
    --with-termlib \
    --with-versioned-syms \
    --enable-widec \
    --disable-lib-suffixes

if [[ "$target_platform" == osx* ]]; then
    # When linking libncurses*.dylib, reexport libtinfo so that later
    # client code linking against just -lncurses also gets -ltinfo.
    sed -i.orig '/^SHLIB_LIST/s/-ltinfo/-Wl,-reexport&/' ncurses/Makefile
fi

make -j ${CPU_COUNT}
make INSTALL="${BUILD_PREFIX}/bin/install -c  --strip-program=${STRIP}" install
make clean
make distclean

# Provide headers in $PREFIX/include/ncurses and symlink them in
# $PREFIX/include and $PREFIX/include/ncursesw.
ln -s -L -r "${PREFIX}/include/ncurses/"* -t "${PREFIX}/include/"
ln -s -L -r "${PREFIX}/include/ncurses" "${PREFIX}/include/ncursesw"

if [[ "$target_platform" != osx* ]]; then
    # Replace the installed libncurses.so with a linker script
    # so that linking against it also brings in -ltinfo.
    DEVLIB=$PREFIX/lib/libncurses.so
    RUNLIB=$(basename $(readlink $DEVLIB))
    rm $DEVLIB
    echo "INPUT($RUNLIB -ltinfo)" > $DEVLIB
fi

shared_libs='ncurses tinfo form menu panel'
for lib in ${shared_libs}; do
    lib_name="lib${lib}"
    for lib_file in "${PREFIX}/lib/${lib_name}"*"${SHLIB_EXT}"*; do
        # Provide symlinks for explicitly named wide char varities for
        # backwards compatibility.
        ln -s -L -r "${lib_file}" "${lib_file%%${lib_name}*}${lib_name}w${lib_file##*${lib_name}}"
    done
    # Explicitly delete static libraries
    rm "${PREFIX}/lib/${lib_name}.a"
done

for lib in ${shared_libs} ncurses++; do
    ln -s -L -r "${PKG_CONFIG_LIBDIR}/${lib}"{,w}".pc"
done
ln -s -L -r "${PREFIX}/bin/ncurses"{,w}"${PKG_VERSION%%.*}-config"

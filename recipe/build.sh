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
    --enable-widec

if [[ "$target_platform" == osx* ]]; then
    # When linking libncurses*.dylib, reexport libtinfow so that later
    # client code linking against just -lncursesw also gets -ltinfow.
    sed -i.orig '/^SHLIB_LIST/s/-ltinfow/-Wl,-reexport&/' ncurses/Makefile
fi

make -j ${CPU_COUNT}
make INSTALL="${BUILD_PREFIX}/bin/install -c  --strip-program=${STRIP}" install
make clean
make distclean

# Provide headers in $PREFIX/include/ncursesw and symlink them in
# $PREFIX/include and $PREFIX/include/ncurses.
ln -s -L -r "${PREFIX}/include/ncursesw/"* -t "${PREFIX}/include/"
ln -s -L -r "${PREFIX}/include/ncursesw" "${PREFIX}/include/ncurses"

if [[ "$target_platform" != osx* ]]; then
    # Replace the installed libncursesw.so with a linker script
    # so that linking against it also brings in -ltinfow.
    DEVLIB=$PREFIX/lib/libncursesw.so
    RUNLIB=$(basename $(readlink $DEVLIB))
    rm $DEVLIB
    echo "INPUT($RUNLIB -ltinfow)" > $DEVLIB
fi

shared_libs='ncurses tinfo form menu panel'
for lib in ${shared_libs}; do
    lib_name="lib${lib}"
    for lib_file in "${PREFIX}/lib/${lib_name}w"*"${SHLIB_EXT}"*; do
        # Provide symlinks for non-wide char varities for
        # backwards compatibility.
        ln -s -L -r "${lib_file}" "${lib_file%%${lib_name}w*}${lib_name}${lib_file##*${lib_name}w}"
    done
    # Explicitly delete static libraries
    rm "${PREFIX}/lib/${lib_name}w.a"
done

for lib in ${shared_libs} ncurses++; do
    ln -s -L -r "${PKG_CONFIG_LIBDIR}/${lib}"{w,}".pc"
done
ln -s -L -r "${PREFIX}/bin/ncurses"{w,}"${PKG_VERSION%%.*}-config"

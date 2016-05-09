#!/bin/bash


if [[ `uname` == 'Darwin' ]];
then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

for USE_WIDEC in false true;
do
    WIDEC_OPT=""
    if [ "${USE_WIDEC}" = true ];
    then
        WIDEC_OPT="--enable-widec"
    fi

    sh ./configure \
	    --prefix=$PREFIX \
	    --without-debug \
	    --without-ada \
	    --without-manpages \
	    --with-shared \
	    --with-pkg-config \
	    --disable-overwrite \
	    --enable-symlinks \
	    --enable-termcap \
	    --enable-pc-files \
	    $WIDEC_OPT \
	    --with-terminfo-dirs=/usr/share/terminfo
    make
    make install
    make clean
    make distclean

    # Provide tinfo files as links to ncurses files.
    LIB_LETTER=""
    if [ "${USE_WIDEC}" = true ];
    then
        LIB_LETTER="w"
    fi
    ln -s "${PREFIX}/lib/libncurses${LIB_LETTER}.a" "${PREFIX}/lib/libtinfo${LIB_LETTER}.a"
    ln -s "${PREFIX}/lib/libncurses${LIB_LETTER}.${DYLIB_EXT}" "${PREFIX}/lib/libtinfo${LIB_LETTER}.${DYLIB_EXT}"
    ln -s "${PREFIX}/lib/pkgconfig/ncurses${LIB_LETTER}.pc" "${PREFIX}/lib/pkgconfig/tinfo${LIB_LETTER}.pc"

    # Provide headers in `$PREFIX/include` and
    # symlink them in `$PREFIX/include/ncurses`
    # and in `$PREFIX/include/ncursesw`.
    HEADERS_DIR="${PREFIX}/include/ncurses"
    if [ "${USE_WIDEC}" = true ];
    then
        HEADERS_DIR="${PREFIX}/include/ncursesw"
    fi
    for HEADER in $(ls $HEADERS_DIR);
    do
        mv "${HEADERS_DIR}/${HEADER}" "${PREFIX}/include/${HEADER}"
        ln -s "${PREFIX}/include/${HEADER}" "${HEADERS_DIR}/${HEADER}"
    done
done

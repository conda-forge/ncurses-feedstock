# set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\share\pkgconfig

sed -i 's!eval `${MAKE-make} -f conftest.make 2>/dev/null | grep temp=`!${MAKE-make} -f conftest.make 2>/dev/null!g' configure

# Some options copied from https://github.com/msys2/MSYS2-packages/blob/master/ncurses/PKGBUILD
bash -x configure \
  --disable-mixed-case \
  --disable-overwrite \
  --disable-relink \
  --disable-rpath \
  --disable-term-driver \
  --disable-termcap \
  --enable-colorfgbg \
  --enable-echo \
  --enable-ext-colors \
  --enable-ext-mouse \
  --enable-pc-files \
  --enable-sigwinch \
  --enable-sp-funcs 
  --enable-tcap-names \
  --enable-widec \
  --with-cxx-shared \
  --with-normal \
  --with-pkg-config \
  --with-shared \
  --with-ticlib \
  --with-versioned-syms \
  --with-wrap-prefix=ncwrap_ \
  --without-ada \
  --without-debug \
  --without-manpages \
  --without-progs \
  --without-termlib \
  --without-tests

make
make install
  
# --with-default-terminfo-dir=/usr/share/terminfo
#   --includedir=/usr/include/ncursesw
# --with-build-cflags=-D_XOPEN_SOURCE_EXTENDED \
# --with-pkg-config-libdir=/usr/lib/pkgconfig

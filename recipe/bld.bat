:: set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\share\pkgconfig

:: From https://github.com/msys2/MSYS2-packages/blob/master/ncurses/PKGBUILD
bash -c "echo before sed; ls -lR"
bash -c 'sed -i \'s!eval `${MAKE-make} -f conftest.make 2>/dev/null | grep temp=`!${MAKE-make} -f conftest.make 2>/dev/null!g\' configure'
bash -c "echo after sed"
if errorlevel 1 exit 1

bash -x configure ^
  --without-ada ^
  --with-shared ^
  --with-cxx-shared ^
  --without-manpages ^
  --disable-overwrite ^
  --with-normal ^
  --without-debug ^
  --with-versioned-syms ^
  --disable-relink ^
  --disable-rpath ^
  --with-ticlib ^
  --without-termlib ^
  --enable-widec ^
  --enable-ext-colors ^
  --enable-ext-mouse ^
  --enable-sp-funcs ^
  --with-wrap-prefix=ncwrap_ ^
  --enable-sigwinch ^
  --disable-term-driver ^
  --enable-colorfgbg ^
  --enable-tcap-names ^
  --disable-termcap ^
  --disable-mixed-case ^
  --with-pkg-config ^
  --enable-pc-files ^
  --enable-echo
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1
  
:: --with-default-terminfo-dir=/usr/share/terminfo
::   --includedir=/usr/include/ncursesw
:: --with-build-cflags=-D_XOPEN_SOURCE_EXTENDED \
:: --with-pkg-config-libdir=/usr/lib/pkgconfig

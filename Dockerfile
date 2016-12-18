FROM apiaryio/emcc:1.36

run apt-get update; apt-get install -y \
	autoconf \
	automake \
	build-essential \
	git \
	libtool \
	pkg-config \
	wget

run mkdir /fractal
run mkdir /fractal/prefix
run mkdir /fractal/source

WORKDIR /fractal/source

# ZLIB

RUN wget http://zlib.net/zlib-1.2.8.tar.gz
RUN tar zxvf zlib-1.2.8.tar.gz

RUN cd zlib* && \
  emconfigure bash -c "CFLAGS=-O2 ./configure --prefix /fractal/prefix" && \
  emmake make -j $(nproc) && \
  emmake make install && \
  cd ..

# LIBPNG

RUN wget https://download.sourceforge.net/libpng/libpng-1.6.21.tar.gz
RUN tar zxvf libpng-1.6.21.tar.gz

RUN cd libpng* && \
  emconfigure bash -c "CPPFLAGS='-I/fractal/prefix/include/' LDFLAGS='-L/fractal/prefix/lib' CFLAGS=-O2 ./configure --prefix=/fractal/prefix --enable-shared=yes" && \
  emmake bash -c "CFLAGS='-L/fractal/prefix/lib/ -I/fractal/prefix/include' make -j $(nproc)" && \
  emmake make install && \
  cd ..

# For some reason this doesn't work...?
#RUN cd libpng* && \
#  emconfigure ./configure --prefix=/fractal/prefix --with-pkgconfigdir=/fractal/prefix && \
#  emmake make -j $(nproc) && \
#  emmake make install && \
#  cd ..

# LIBJPEG

RUN wget https://download.sourceforge.net/libjpeg/jpegsrc.v6b.tar.gz
RUN tar zxvf jpegsrc.v6b.tar.gz

RUN cd jpeg-6b && \
  cp /usr/share/automake-1.14/config.* . && \
  emconfigure bash -c "CFLAGS=-O2 ./configure --prefix=/fractal/prefix --enable-shared" && \
  emmake make -j $(nproc) && \
  mkdir -p /fractal/prefix/man/man1 && \
  emmake make install && \
  cd ..

# LIBGD2

RUN wget https://github.com/libgd/libgd/releases/download/gd-2.2.3/libgd-2.2.3.tar.gz
RUN tar xzvf libgd-2.2.3.tar.gz

RUN cd libgd* && \
  emconfigure bash -c "CFLAGS=-Wno-error PKG_CONFIG_LIBDIR=/fractal/prefix/lib/pkgconfig:$PKG_CONFIG_LIBDIR ./configure --prefix /fractal/prefix --with-zlib --with-png --with-jpeg=/fractal/source/jpeg-6b/ --enable-shared=yes" && \
  emmake make -j $(nproc) && \
  emmake make install && \
  cd ..

# Fractal

RUN git clone http://github.com/allanlw/fractal.git

RUN apt-get install -y build-essential

RUN cd fractal && \
    autoreconf -i && \
    emconfigure bash -c "CPPFLAGS='-I/fractal/prefix/include' LDFLAGS='-L/fractal/prefix/lib' ./configure --prefix=/fractal/prefix" && \
    emmake make -j $(nproc) && \
    cd ..

# Build output javascript

ADD fractal-js fractal-js

WORKDIR fractal-js
RUN ln -s ../fractal/src/fractal fractal.bc && \
    emcc -o fractal.js fractal.bc -L/fractal/prefix/lib/ /fractal/prefix/lib/libz.so -lpng -ljpeg -lgd --pre-js pre-js.js -s FORCE_FILESYSTEM=1 -v -s EXPORTED_FUNCTIONS="['_main']" -O2  -s DISABLE_EXCEPTION_CATCHING=0 -s ALLOW_MEMORY_GROWTH=1 --closure 1 -g2

EXPOSE 8080

ENTRYPOINT python -m SimpleHTTPServer 8080

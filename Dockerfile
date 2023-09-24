FROM ubuntu:latest as glibc-builder
RUN apt-get update
# Prepping for glibc build
RUN apt-get install --no-install-recommends git build-essential -y 
RUN apt-get install --no-install-recommends gawk bison python3 python3-pip -y
# Start building glibc
RUN git clone --depth=1 https://sourceware.org/git/glibc.git /tmp/glibc
RUN mkdir /tmp/build
WORKDIR /tmp/build
RUN ../glibc/configure \
         --prefix=/tmp/install \
         --host=x86_64-linux-gnu \
         --build=x86_64-linux-gnu \
         CC="gcc -m64" \
         CXX="g++ -m64" \
         CFLAGS="-O2" \
         CXXFLAGS="-O2"
RUN make -j4
RUN make -j4 install
RUN mv /tmp/install /lib64

FROM alpine
# Transfer over glibc from builder
COPY --from=glibc-builder /lib64 /lib64
# Restore symlink with functioning symlink
RUN ln -sf /lib64/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
WORKDIR /lib64
RUN rm -rf lib/
WORKDIR /lib64/lib
# Add libs from built glibc to /lib64 so LD can detect it.
RUN cp -r . /lib64
WORKDIR /

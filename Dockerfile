FROM ubuntu:latest as glibc-builder
RUN apt-get update
# Prepping for glibc build
RUN apt-get install --no-install-recommends git build-essential -y 
RUN apt-get install --no-install-recommends gawk bison python3 python3-pip -y
RUN apt-get install --no-install-recommends lld -y
# Start building glibc
RUN git clone --depth=1 https://sourceware.org/git/glibc.git /tmp/glibc
RUN mkdir -p /root/bin/lld
RUN printf "#!/bin/bash\nlld "$@"" > /root/bin/lld/ld
RUN chmod a+x /root/bin/lld/ld
RUN mkdir /tmp/build
WORKDIR /tmp/build
RUN ../glibc/configure \
         --prefix=/libs \
         --host=x86_64-linux-gnu \
         --build=x86_64-linux-gnu \
         CC="gcc -m64" \
         CXX="g++ -m64" \
         CFLAGS="-O2 -B/root/bin/lld" \
         CXXFLAGS="-O2 -B/root/bin/lld"
RUN make -j4
RUN make -j4 install

FROM alpine
# LD is blind and wont detect /lib64 so set LD_LIBRARY_PATH to detect /lib64
ENV LD_LIBRARY_PATH=/lib:/lib64:/usr/lib
# Transfer over glibc from builder
COPY --from=glibc-builder /libs /lib64
WORKDIR /lib64/install/lib
RUN cp ./ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
RUN mkdir -p /libs
RUN cp -r . /libs/lib
WORKDIR /lib64
WORKDIR /root

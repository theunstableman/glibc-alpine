# Warning: spaghetti code
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
         --prefix=/tmp/install \
         --host=x86_64-linux-gnu \
         --build=x86_64-linux-gnu \
         CC="gcc -m64" \
         CXX="g++ -m64" \
         CFLAGS="-O2 -B/root/bin/lld" \
         CXXFLAGS="-O2 -B/root/bin/lld"
RUN make -j4
RUN make -j4 install
RUN mv /tmp/install /lib64

FROM alpine
# LD is blind and wont detect /lib64 so set LD_LIBRARY_PATH to detect /lib64
ENV LD_LIBRARY_PATH=/lib:/lib64:/usr/lib
# Transfer over glibc from builder
COPY --from=glibc-builder /lib64 /lib64
WORKDIR /lib64/install/lib
# Add libs from built glibc to /lib64 so LD can detect it.
RUN cp -r . /lib64
# Fix for people who use this for multistage dockerfile builds.
RUN mkdir -p /tmp/install/lib
RUN cp -r . /tmp/install/lib
WORKDIR /lib64
RUN rm -r install/
WORKDIR /root

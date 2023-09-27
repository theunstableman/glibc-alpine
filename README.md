# glibc-alpine
Glibc in alpine

[![CI Build](https://github.com/theunstableman/glibc-alpine/actions/workflows/build.yml/badge.svg)](https://github.com/theunstableman/glibc-alpine/actions/workflows/build.yml)

## Quick start

`docker run -it --rm karrelin/glibc-alpine`

That's it. You have glibc installed in alpine linux!


## Building
To build, first clone the repo:
```git clone https://github.com/theunstableman/glibc-alpine```

Then, enter the repo:
`cd glibc-alpine`

Finally, build the image:
`docker build . -t glibc-alpine`

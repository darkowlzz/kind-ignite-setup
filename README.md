## Building binaries

Use dapper to build the binaries in a container.
```
$ dapper
```
This will build the binaries in docker and copy the binaries in `bin/` dir.

The binaries can be built on the host but it can overwrite any local copy of
kind and iginte on the host GOPATH. Use `make binaries` to build the binaries on
host. The binaries will be copied to `bin/` dir.


## Building images

Kind node images are built on the host.
```
make images
```

Images can also be built in a container image. Change the entrypoint in
`Dockerfile.dapper` to use make target `all`. The images are saved as tar files
in `bin/`. They can be imported by the continer engine.

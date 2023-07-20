# Electron 22, Debianized

Currently all job is done through shell scripts; Will build on Debian package structure later on.

Fetch necessary repos (Chromium, Electron):

```console
$ ./fetch.sh
```

Create source directory structure from repos, with pruning and cleaning:

```
$ ./source.sh
```

(Optional) Pack source directory like Debian's .orig.tar.xz:

```
$ ./pack-source.sh
```

Start building:

```
$ ./prepare.sh
$ ./build.sh
```

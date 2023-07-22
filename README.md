# Electron 22, Debianized

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
$ ln -s ../debian electron-22-*/
$ cd electron-22-*/
$ dpkg-buildpackage -us -uc
```

## Why put all the code in `src/` directory and not directly in the root?

Some Electron scripts run before packing actually depend on this file structure, and I didn't bother move them into a different name. Also, this is what Arch Linux did in their build scripts (although they do not need something like .orig.tar)

As a side effect, I find this hierachy easy to let me work on Debian-specific stuff, since there are so many directories and files inside Chromium source's root.

# Electron Debianized

Packaging Electron as .deb dependency for applications e.g. VS Code, just like what Arch Linux did. Currently version 22 and 23 is packaged.

Since Electron (together with Chromium) is so huge, and I don't really want to bother using git-buildpackage or something on such package. Also, some preparation done by either Chromium or Electron *needs* to be in a Git repository. So I've settled on only uploading debian/ directory, and creating tarball using scripts from projects' Git repositories.

Coincidentally, this is also how openSUSE packaged [their Electron](https://build.opensuse.org/package/view_file/openSUSE:Factory/nodejs-electron/create_tarball.sh).

## Building

0. Install yarn:

```console
# apt install yarnpkg
```

1. Fetch necessary repos (Chromium, Electron):

```console
$ debian/rules fetch-repos
```

2. Create source directory structure from repos, with pruning and cleaning:

```
$ debian/rules create-source
```

3. (Optional) Pack source directory. The result should be a ~737M tarball:

```
$ debian/rules pack-tarball
```

4. Start building:

```
$ ln -s electron-<major>-<version>.tar.xz electron-<major>_<version>.orig.tar.xz
$ cd electron-<major>-<version>/
$ cp -r ../debian .
$ dpkg-buildpackage -us -uc  # or
$ sbuild ...
```

## Building on riscv64

This package also includes unofficial support for riscv64, as first done in [Arch Linux RISC-V](https://github.com/felixonmars/archriscv-packages/tree/master/electron22).

Note that since Google doesn't build depot_tools for riscv64 (and fortunately it is only used in preparation), you need to:

  1. Follow the step 1-3 above
  2. Move the tarball to the riscv64 machine and extract it
  3. Finish step 4

## Sidenote

### Why put all the code in `src/` directory and not directly in the root?

Some Electron scripts run before packing actually depend on this file structure, and I didn't bother move them into a different name. Also, this is what Arch Linux did in their build scripts (although they do not need something like .orig.tar)

As a side effect, I find this hierachy easy to let me work on Debian-specific stuff, since there are so many directories and files inside Chromium source's root.

set -e
shopt -s dotglob
source metadata.sh

_dirname=$_pkgname-$_electron_ver
_dirpath=$(realpath $_dirname)
cd $_dirname/src

# apply patches
ln -s ../../patches patches
quilt push -a

# use system node w/out patching source; upstream hardcodes x64 in path
mkdir -p third_party/node/linux/node-linux-x64/bin
ln -sf /usr/bin/node third_party/node/linux/node-linux-x64/bin

# prefer unbundled (system) libraries
# ./debian/scripts/unbundle
../../unbundle.py

( cd .. && \
  src/electron/script/apply_all_patches.py src/electron/patches/config.json )

cd electron
yarnpkg install --frozen-lockfile

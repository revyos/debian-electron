set -e
shopt -s dotglob
source metadata.sh

_dirname=$_pkgname-$_electron_ver
_dirpath=$(realpath $_dirname)
cd $_dirname/src

# apply patches
ln -sf ../../patches patches
quilt push -a

# use system node w/out patching source; upstream hardcodes x64 in path
mkdir -p third_party/node/linux/node-linux-x64/bin
ln -sf /usr/bin/node third_party/node/linux/node-linux-x64/bin

# same for openjdk
ln -s /usr/lib/jvm/java-11-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH) \
  third_party/jdk/current

# prefer unbundled (system) libraries
../../unbundle.py

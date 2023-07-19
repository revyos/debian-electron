set -e
shopt -s dotglob
source metadata.sh

_dirname=$_pkgname-$_electron_ver
_dirpath=$(realpath $_dirname)
cd $_dirname

# remove unused files (mainly to shrink size)
readarray -t _files_excluded < ../files-excluded
for _f in ${_files_excluded[@]}; do
  rm -rfv src/$_f
done

# use system node w/out patching source; upstream hardcodes x64 in path
mkdir -p src/third_party/node/linux/node-linux-x64/bin
ln -sf /usr/bin/node src/third_party/node/linux/node-linux-x64/bin

# prefer unbundled (system) libraries
# ./debian/scripts/unbundle
pushd src
../../unbundle.py
popd

src/electron/script/apply_all_patches.py src/electron/patches/config.json

# link patches folder
# quilt push -a

cd src/electron
yarnpkg install --frozen-lockfile

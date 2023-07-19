set -e
shopt -s dotglob
source metadata.sh

_dirname=$_pkgname-$_electron_ver

rm -rf $_dirname
mkdir $_dirname{,/src}
_dirpath=$(realpath $_dirname)
cd $_dirname

pushd ../repos/chromium
git checkout $_chromium_ver
cp -rv * $_dirpath/src
popd

pushd ../repos/electron
git checkout v$_electron_ver
popd

cat > .gclient <<EOF
solutions = [
  {
    "name": "src/electron",
    "url": "file://$(dirname $_dirpath)/repos/electron@v$_electron_ver",
    "deps_file": "DEPS",
    "managed": False,
    "custom_deps": {
      "src": None,
    },
    "custom_vars": {},
  },
]
EOF

_oldpath=$PATH
export PATH+=":$(dirname $_dirpath)/repos/depot_tools" DEPOT_TOOLS_UPDATE=0

gclient sync -D \
  --nohooks \
  --with_branch_heads \
  --with_tags

echo "Running hooks..."
src/build/landmines.py
src/build/util/lastchange.py -o src/build/util/LASTCHANGE
src/build/util/lastchange.py -m GPU_LISTS_VERSION \
  --revision-id-only --header src/gpu/config/gpu_lists_version.h
src/build/util/lastchange.py -m SKIA_COMMIT_HASH \
  -s src/third_party/skia --header src/skia/ext/skia_commit_hash.h
src/build/util/lastchange.py \
  -s src/third_party/dawn --revision src/gpu/webgpu/DAWN_VERSION
src/tools/update_pgo_profiles.py --target=linux update \
  --gs-url-base=chromium-optimization-profiles/pgo_profiles
download_from_google_storage --no_resume --extract --no_auth \
  --bucket chromium-nodejs -s src/third_party/node/node_modules.tar.gz.sha1

export PATH=$_oldpath
unset DEPOT_TOOLS_UPDATE

# remove unused files (mainly to shrink size)
readarray -t _files_excluded < ../files-excluded
for _f in ${_files_excluded[@]}; do
  rm -rf $_f
done


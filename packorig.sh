# shopt -s extglob
shopt -s dotglob
set -e

source versions.sh
_dirname=electron-22-orig

rm -rf $_dirname
mkdir $_dirname{,/src}
_dirpath=$(realpath $_dirname)
cd $_dirname

pushd ../repos/chromium
# git checkout $_chromium_ver
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

### These should be executed in debian/rules, debianized
### As well as replacing vendored dependencies using system ones
# # Create sysmlink to system clang-format
# ln -s /usr/bin/clang-format src/buildtools/linux64
# # Create sysmlink to system Node.js
# mkdir -p src/third_party/node/linux/node-linux-x64/bin
# ln -sf /usr/bin/node src/third_party/node/linux/node-linux-x64/bin
# src/electron/script/apply_all_patches.py \
#   src/electron/patches/config.json
# cd src/electron || exit
# yarn install --frozen-lockfile
# cd ..


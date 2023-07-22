set -e
source metadata.sh

_root=$PWD
_dirname=$_pkgname-$_electron_ver
rm -rf $_dirname
mkdir $_dirname
_dirpath=$(realpath $_dirname)
cd $_dirname

( cd ../repos/electron && git checkout v$_electron_ver )

( cd ../repos/chromium && \
  git checkout $_chromium_ver && \
  cp -r --reflink=auto . $_dirpath/src )

cat > .gclient <<EOF
solutions = [
  {
    "name": "src/electron",
    "url": "file://$_root/repos/electron@v$_electron_ver",
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
export PATH+=":$_root/repos/depot_tools"
export DEPOT_TOOLS_UPDATE=0

gclient sync -D --nohooks --with_branch_heads --with_tags

cd src

echo "Running hooks..."
python3 build/landmines.py
python3 build/util/lastchange.py -o build/util/LASTCHANGE
python3 build/util/lastchange.py -m GPU_LISTS_VERSION \
  --revision-id-only --header gpu/config/gpu_lists_version.h
python3 build/util/lastchange.py -m SKIA_COMMIT_HASH \
  -s third_party/skia --header skia/ext/skia_commit_hash.h
python3 build/util/lastchange.py \
  -s third_party/dawn --revision gpu/webgpu/DAWN_VERSION
python3 tools/update_pgo_profiles.py --target=linux update \
  --gs-url-base=chromium-optimization-profiles/pgo_profiles
download_from_google_storage --no_resume --extract --no_auth \
  --bucket chromium-nodejs -s third_party/node/node_modules.tar.gz.sha1

export PATH=$_oldpath
unset DEPOT_TOOLS_UPDATE

# apply electron patches beforehand since they need git to apply
( cd .. && \
  src/electron/script/apply_all_patches.py \
    src/electron/patches/config.json )

# same as yarn install
( cd electron && yarnpkg install --frozen-lockfile )

# remove unused files (mainly to shrink size)
readarray -t _files_excluded < ../../files-excluded.txt
for _f in "${_files_excluded[@]}"; do
  if [ -n "$_f" ] && [[ "$_f" != "#"* ]]; then
    for _g in $(bash -O dotglob -O extglob -O globstar -c "echo $_f"); do
      rm -rfv $_g
    done
  fi
done

find . -type d -empty -print -delete
find . -type d -name .git -print0 | xargs -0 rm -rf
find . -type d -name __pycache__ -print0 | xargs -0 rm -rf
find .. -mindepth 1 -maxdepth 1 ! -name src -print0 | xargs -0 rm -rf

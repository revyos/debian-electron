source versions.sh

_dir=repos

if [ ! -d $_dir ]; then
  mkdir $_dir
fi

git clone https://github.com/chromium/chromium $_dir/chromium \
  --depth 1 \
  --branch $_chromium_ver
git clone https://github.com/electron/electron.git $_dir/electron \
  --branch v$_electron_ver
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $_dir/depot_tools

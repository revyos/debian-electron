source metadata.sh

_dir=repos

if [ ! -d $_dir ]; then
  mkdir $_dir
fi

git clone https://salsa.debian.org/chromium-team/chromium.git \
  $_dir/debian-chromium \
  --branch debian/$_deb_chromium_ver
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/electron22.git \
  $_dir/archlinux-electron22

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git \
  $_dir/depot_tools
git clone https://github.com/electron/electron.git \
  $_dir/electron \
  --branch v$_electron_ver
git clone https://github.com/chromium/chromium \
  $_dir/chromium \
  --branch $_chromium_ver

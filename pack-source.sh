set -e
source metadata.sh

_dirname=$_pkgname-$_electron_ver

bsdtar -cf - $_dirname | xz -T0 > $_dirname.tar.xz

set -e
_dirname=$RULES_pkgname-$RULES_electron_ver
bsdtar -cf - $_dirname | xz -T0 > $_dirname.tar.xz

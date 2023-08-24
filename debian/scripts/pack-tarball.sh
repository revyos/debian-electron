#!/bin/bash

set -e
_dirname=$RULES_pkgname-$RULES_electron_ver
tar cf - $_dirname | xz -T0 > $_dirname.tar.xz

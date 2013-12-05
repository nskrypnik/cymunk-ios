#!/bin/sh

#  build-cymunk.sh
#  
#
#  Created by Niko Skrypnik on 11/14/13.
#

. $(dirname $0)/environment.sh


if [ ! -d $TMPROOT/cymunk ] ; then
try pushd $TMPROOT
try git clone https://github.com/nskrypnik/cymunk
try cd cymunk
try popd
fi

if [ "X$1" = "X-f" ] ; then
try pushd $TMPROOT/cymunk
try git clean -dxf
try git pull origin master
try popd
fi

pushd $TMPROOT/cymunk

OLD_CC="$CC"
OLD_CFLAGS="$CFLAGS"
OLD_LDFLAGS="$LDFLAGS"
OLD_LDSHARED="$LDSHARED"
export CC="$ARM_CC -I$BUILDROOT/include"
export CFLAGS="$ARM_CFLAGS"
export LDFLAGS="$ARM_LDFLAGS"
export LDSHARED="$KIVYIOSROOT/tools/liblink"

ln -s $KIVYIOSROOT/Python-$IOS_PYTHON_VERSION/python
ln -s $KIVYIOSROOT/Python-$IOS_PYTHON_VERSION/python.exe

rm -rdf iosbuild/
try mkdir iosbuild

echo "First build ========================================"
HOSTPYTHON=$TMPROOT/Python-$IOS_PYTHON_VERSION/hostpython
$HOSTPYTHON setup.py build_ext -g
echo "compile cython code =========================================="
cython ./cymunk/python/cymunk.pyx
echo "Second build ======================================="
try $HOSTPYTHON setup.py build_ext -g
try $HOSTPYTHON setup.py install -O2 --root iosbuild
# Strip away the large stuff
rm -rdf "$BUILDROOT/python/lib/python2.7/site-packages/cymunk.so"
# Copy to python for iOS installation
try cp -R "iosbuild/usr/local/lib/python2.7/site-packages/cymunk.so" "$BUILDROOT/python/lib/python2.7/site-packages"
echo "Cymunk was copied to site-packages"

export CC="$OLD_CC"
export CFLAGS="$OLD_CFLAGS"
export LDFLAGS="$OLD_LDFLAGS"
export LDSHARED="$OLD_LDSHARED"
popd

bd=$TMPROOT/cymunk/build/lib.macosx-*
try $KIVYIOSROOT/tools/biglink $BUILDROOT/lib/libcymunk.a $bd
deduplicate $BUILDROOT/lib/libcymunk.a

#!/bin/bash
for i in `cat packages-deps_x264.1.txt`; do
    if ! [ -d $i ]; then
        rfpkg clone free/$i
        pushd $i
    else
        pushd $i
        git checkout master
        git pull
    fi
    rpmdev-bumpspec -c "Mass rebuild for x264-0.164" $i.spec
    rfpkg ci -c && git show
    echo Press enter to continue; read dummy;
    rfpkg push && rfpkg build --nowait
    popd
done

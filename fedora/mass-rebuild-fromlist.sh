#!/bin/bash

for i in `cat list_to_rebuild.txt`; do
    #koji list-tagged f39-python | grep $i
    if ! [ -d $i ]; then
        fedpkg clone $i
        pushd $i
        git --no-pager log --pretty=tformat:"%C(yellow)%h %C(cyan)%ad %Cblue%an%C(auto)%d %Creset%s" --graph --date=format:"%Y-%m-%d %H:%M" -4
        echo Press enter to upload sources and commit or n to skip; read dummy;
        if [[ "$dummy" != "n" ]]; then
            rpmdev-bumpspec -c "Mass rebuild for jpegxl-0.8.1" $i.spec
            git commit --allow-empty -m "Mass rebuild for jpegxl-0.8.1" . && git show
            echo Press enter to continue; read dummy;
            fedpkg push && fedpkg build --nowait --target=f39-build-side-69182
        fi
        popd
    else
        pushd $i
        echo "please check $i"
        git checkout rawhide
        git pull
        git --no-pager log --pretty=tformat:"%C(yellow)%h %C(cyan)%ad %Cblue%an%C(auto)%d %Creset%s" --graph --date=format:"%Y-%m-%d %H:%M" -4
        popd
    fi
done

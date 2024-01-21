#!/bin/bash
MSG="Rebuild for SFML-2.6.1"
sidetag=f40-build-side-77060

for i in `cat list_to_rebuild.txt`; do
    #koji list-tagged f39-python | grep $i
    if ! [ -d $i ]; then
        fedpkg clone $i
        pushd $i
        git --no-pager log --pretty=tformat:"%C(yellow)%h %C(cyan)%ad %Cblue%an%C(auto)%d %Creset%s" --graph --date=format:"%Y-%m-%d %H:%M" -4
        echo Press enter to commit and build on side-tag or n to skip; read dummy;
        if [[ "$dummy" != "n" ]]; then
            rpmdev-bumpspec -c "$MSG" $i.spec
            git commit --allow-empty -m "$MSG" . && git show
            echo Press enter to continue; read dummy;
            fedpkg push && fedpkg build --nowait --target=$sidetag
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

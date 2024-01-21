#./ffmpegthumbs/ffmpegthumbs.spec
#./kdenlive/kdenlive.spec
#./k3b-extras-freeworld/k3b-extras-freeworld.spec
#./kwave

rawhide=40
REPOS="f39 f38 el9 el8 el7"
#name=$1
version_kde=22.08.1

echo "Usage: $0 version stage"
echo "stage 0: rpmdev-bumpspec"
echo "stage 1: scratch-build"
echo "stage 2: rfpkg new-sources && rfpgk ci -c"
echo "stage 3: push and build on rawhide"
echo "stage 4: build"
echo $(basename $(pwd))
name=$(basename $(pwd))
if [ ! -f $name.spec ]; then
    echo "File $name.spec not found!"
    exit 1
fi

if [ -z "$1" ]
then
      version=$version_kde
else
      version=$1
fi

if [ -z "$2" ]
then
      stage=0
else
      stage=$2
fi

if test $stage -le 0
then
echo STAGE 0
git checkout master
git pull
fi

if test $stage -le 1
then
echo STAGE 1
echo "press enter run rpmdev-bumpspec -n $version -c \"Update $name to $version\" $name.spec n to skip"; read dummy;
if [[ "$dummy" != "n" ]]; then
rpmdev-bumpspec -n $version -c "Update $name to $version" $name.spec
fi
spectool -g $name.spec
echo "press enter rfpkg mockbuild -N --default-mock-resultdir --root fedora+rpmfusion_free-38-x86_64 or n to skip"; read dummy;
if [[ "$dummy" != "n" ]]; then
rfpkg mockbuild -N --default-mock-resultdir --root fedora+rpmfusion_free-38-x86_64
fi
echo Press enter scratch-build or n to skip; read dummy;
if [[ "$dummy" != "n" ]]; then
rfpkg scratch-build --srpm --fail-fast
fi
fi

if test $stage -le 2
then
echo STAGE 2
echo Press enter to rfpkg new-sources and rfpkg ci -c or n to skip; read dummy;
#rfpkg new-sources $name-$VERSION.tar.xz
if [[ "$dummy" != "n" ]]; then
    #rfpkg new-sources $(spectool -l --sources $name.spec | grep / | sed 's/.*\///')
    rfpkg new-sources $(spectool -l --sources $name.spec | grep / | sed 's/.*: //;s/.*\///')
    rfpkg ci -c
    git show
fi
fi
if test $stage -le 3
then
echo STAGE 2
echo Press enter to push and build in current branch; read dummy;
rfpkg push && rfpkg build --fail-fast
fi

echo STAGE 4
for repo in $REPOS ; do
echo Press enter to build on branch $repo or n to skip; read dummy;
if [[ "$dummy" != "n" ]]; then
    git checkout $repo && git merge master && git push && rfpkg build --nowait --fail-fast; git checkout master
fi
done

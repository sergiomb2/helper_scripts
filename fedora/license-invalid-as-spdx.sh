#!/usr/bin/bash

SPEC="$1"
FILENAME_ALL_PACKAGES="final_just_packages.txt"
POSITIVE=""
package=$(basename $(pwd))

git checkout rawhide
git pull
grep '^License:' ${package}.spec | cut '-d:' -f2- | \
while read -r LICENSE; do
  if license-validate --old "$LICENSE" >/dev/null;  then
        if license-validate "$LICENSE" >/dev/null; then
                echo "$1 warning: valid as old and new and no changelong entry, please check: $LICENSE"
        else
                if license-fedora2spdx "$LICENSE" | grep Warning >/dev/null; then
                        # this is not straight forward conversion
                        echo "$1"
                else
                        SPDXLICENSE=$(license-fedora2spdx "$LICENSE")
                        echo "$1 - can be trivially converted to $SPDXLICENSE"
                        sed -i "s/$LICENSE/$SPDXLICENSE/" "${package}.spec"
                        rpmdev-bumpspec -c "Migrate to SPDX license format" $package.spec
                        fedpkg ci -c || git commit -m "${bugs_str}"
                fi
        fi
else
        if license-validate "$LICENSE" >/dev/null; then
                true;
        else
                echo "$1 warning: not valid neither as Callaway nor as SPDX, please check"
                echo "${SPEC}" >> $FILENAME_ALL_PACKAGES
        fi
  fi
done

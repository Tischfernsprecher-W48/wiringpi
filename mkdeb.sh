#!/bin/bash

export DEBEMAIL="lan4lano@gmail.com"
export DEBFULLNAME="Sven Moennich"
export LOGNAME="Sven Moennich" 

PROGRAMM=w48conf

command -v dh_make >/dev/null 2>&1 || { echo >&2 "I require dh_make but it's not installed.  Aborting."; exit 1; }
command -v debuild >/dev/null 2>&1 || { echo >&2 "I require debuild but devscripts it's not installed.  Aborting."; exit 1; }
command -v mkversion >/dev/null 2>&1 || { echo >&2 "I require mkversion but it's not installed.  Aborting."; exit 1; }

# Release festlegen
# 0 für Benutzer fragen
release_num=0

RELEASE=( "" "major release" "minor release" "patch level" "build" )
typeset -i i=1 max=${#RELEASE[*]}
if [ "${release_num}" -lt 1 ]
then
[ -f .last_version.number ] && echo "Alte Version: $(cat .last_version.number)" || mkversion >.last_version.number
echo ""
while (( i < max ))
do
   echo "${i}: New - ${RELEASE[${i}]}"
   i=i+1
done
echo ""
    read -n 1 -p "Bitte wählen sie eine Release Version aus: " release_num >/dev/null && echo ""
fi
[[ "${release_num}" =~ ^-?[1-$((max-1))]+$ ]] || { echo "ERROR: Aborting."; exit 1; }

# Version updaten
CUSTOM_VERSION=`mkversion "$(cat .last_version.number)" $release_num >.last_version.number && cat .last_version.number`
echo "Neue Version: ${CUSTOM_VERSION}"


TMPDIR=$(mktemp -d)
SRCDIR=$(pwd)
DSTDIR=$TMPDIR/$PROGRAMM-${CUSTOM_VERSION}
mkdir -p $DSTDIR

cp -r $SRCDIR/* $DSTDIR/
rm -rf $DSTDIR/.git

cd $DSTDIR

dh_make --indep --createorig --copyright gpl --yes

rm debian/*.ex debian/*.EX debian/README.Debian debian/README.source 

cat <<EOF >debian/install
$PROGRAMM usr/sbin
EOF

debuild -us -uc

cd ..
cp *.deb $SRCDIR

rm -rf $TMPDIR

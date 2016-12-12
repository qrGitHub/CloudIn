#!/bin/bash

doCommand() {
	echo "^_^ doCommand: $*"
	eval "$@"
	[ $? -eq 0 ] || exit 1
}

installDependsTool=installDependPkgs.sh
aptCacheDir=/var/cache/apt/archives
prepareLogFile=log.prepare
dependPkgDir=dependPkgs

doCommand "bash prepare.sh | tee $prepareLogFile"

echo '#!/bin/bash' > $installDependsTool
echo -e '\ndoCommand() {' >> $installDependsTool
echo -e '\techo "^_^ doCommand: $*"' >> $installDependsTool
echo -e '\teval "$@"' >> $installDependsTool
echo -e '\t[ $? -eq 0 ] || exit 1' >> $installDependsTool
echo -e '}\n' >> $installDependsTool
echo -e 'cd '$dependPkgDir'\n' >> $installDependsTool

doCommand mkdir -p $dependPkgDir
for pkg in $(grep 'Preparing to unpack' $prepareLogFile | awk '{print $4}' | awk -F'/' '{print $2}')
do
	doCommand cp $aptCacheDir/$pkg $dependPkgDir
	echo doCommand dpkg -i $pkg >> $installDependsTool
done

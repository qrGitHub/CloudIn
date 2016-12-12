#!/bin/bash

openSSHKey() {
	grep -E '^'$1' (yes|no)$' $sshConfigFile > /dev/null
	if [ $? -eq 0 ]; then
		# Do not replace <KEY yes>
		sed -i 's/^'$1' no/'$1' yes/' $sshConfigFile
	else
		grep -E '^#'$1' (yes|no)$' $sshConfigFile > /dev/null
		if [ $? -eq 0 ]; then
			sed -i 's/^#'$1' \(yes\|no\)/'$1' yes/' $sshConfigFile
		else
			sed -i -e "\$a$1 yes" $sshConfigFile
		fi
	fi
}

setSSHKey() {
	grep -E  '^[# ]*'$2' ' $1
	if [ $? -eq 0 ]; then
		sed -i 's{^[# ]*'$2' .*${'$2' '$3'{' $1
	else
		sed -i -e "\$a$2 $3" $1
	fi
}

doCommand() {
	echo "^_^ $FUNCNAME: $*"
	eval "$@"
	[ $? -eq 0 ] || exit 1
}

if [ ! "$BASH_VERSION" ]; then
	echo "Please use bash to run this script ($0)" 1>&2
	exit 1
fi

sshdConfigFile=/etc/ssh/sshd_config
doCommand setSSHKey $sshdConfigFile PubkeyAuthentication yes
doCommand setSSHKey $sshdConfigFile RSAAuthentication yes

# disable ssh timeout
doCommand setSSHKey $sshdConfigFile ClientAliveInterval 120
doCommand setSSHKey $sshdConfigFile ClientAliveCountMax 3

sshConfigFile=/etc/ssh/ssh_config
# Do not create file "~/known_hosts"
#doCommand setSSHKey $sshConfigFile UserKnownHostsFile /dev/null
# shut down log "The authenticity of host 192.168.0.xxx can't be established."
doCommand setSSHKey $sshConfigFile StrictHostKeyChecking no

doCommand service ssh restart
doCommand ssh-keygen -t rsa
doCommand "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"

#ipAddr=$(ifconfig | grep "inet addr:.*Bcast:" | awk '{print $2}' | awk -F':' '{print $2}')
#ssh $ipAddr

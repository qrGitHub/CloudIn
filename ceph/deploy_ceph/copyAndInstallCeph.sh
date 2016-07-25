hostList=(ceph21 ceph22 ceph23)

for host in ${hostList[@]}
do
    #scp -r debpkg $host:/root/

    ssh $host "cd debpkg && bash installDependPkgs.sh"
    [ $? -eq 0 ] || exit 1

    ssh $host "cd debpkg && bash prepare.sh"
    [ $? -eq 0 ] || exit 1

    ssh $host "cd debpkg && bash install.sh"
    [ $? -eq 0 ] || exit 1
done

ceph health detail > HEALTH_ERR.$(date +%y%m%d%H%M%S)
ceph health detail | grep ^pg | awk '{print $2}' | xargs -n 1 ceph pg repair

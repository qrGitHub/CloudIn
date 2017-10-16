#!/bin/bash

# Quotas
# set quota of bucket to 20000 objects and 2GB capacity
radosgw-admin quota set --uid=demo --bucket=DEMO07 --max-objects=20000 --max-size=2147483648
# enable quota of bucket 'DEMO07'
#radosgw-admin quota enable --uid=demo --bucket=DEMO07
# disable quota of bucket 'DEMO07'
#radosgw-admin quota set --uid=demo --bucket=DEMO07 --max-objects=-1 --max-size=-1
#radosgw-admin quota disable --uid=demo --bucket=DEMO07

#####################################
# Capacity used and objects count
radosgw-admin bucket stats --uid=demo
# buckets count
radosgw-admin bucket list
# requests count
radosgw-admin usage show --uid=demo

#####################################
# user info
radosgw-admin user info --uid=demo
# create Key
radosgw-admin key create --uid=demo --key-type=s3 --gen-access-key --gen-secret
# remove Key
radosgw-admin key rm --uid=demo --access-key=

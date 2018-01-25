set -e
set -x

pool_create() {
    ceph osd pool create "$1" "$2" "$2" replicated "$3"
    ceph osd pool set "$1" size 2
}

zone=hk1

pool_create .rgw.root 64 replicated_ruleset_sata
pool_create ${zone}.rgw.control 64 replicated_ruleset_sata
pool_create ${zone}.rgw.data.root 64 replicated_ruleset_sata
pool_create ${zone}.rgw.gc 64 replicated_ruleset_sata
pool_create ${zone}.rgw.log 64 replicated_ruleset_sata
pool_create ${zone}.rgw.intent-log 64 replicated_ruleset_sata
pool_create ${zone}.rgw.meta 64 replicated_ruleset_sata
pool_create ${zone}.rgw.usage 64 replicated_ruleset_sata
pool_create ${zone}.rgw.users.keys 64 replicated_ruleset_sata
pool_create ${zone}.rgw.users.email 64 replicated_ruleset_sata
pool_create ${zone}.rgw.users.uid 64 replicated_ruleset_sata
pool_create ${zone}.rgw.buckets.non-ec 64 replicated_ruleset_sata
pool_create ${zone}.rgw.buckets.data 2048 replicated_ruleset_sata
pool_create ${zone}.rgw.buckets.index 2048 replicated_ruleset_ssd

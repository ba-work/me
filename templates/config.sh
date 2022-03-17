#!/bin/bash
set -euxo pipefail

# kernel tweaks to be inline with AKS defaults
# source: https://docs.microsoft.com/en-us/azure/aks/custom-node-configuration#linux-os-custom-configuration
declare -A tweaks=(
    # file system
    [fs.file-max]=709620
    [fs.inotify.max_user_watches]=1048576
    [fs.aio-max-nr]=65536
    [fs.nr_open]=1048576

    # networking core
    [net.core.somaxconn]=16384
    [net.core.netdev_max_backlog]=1000
    [net.core.rmem_max]=212992
    [net.core.wmem_max]=212992
    [net.core.optmem_max]=20480

    # ipv4/tcp
    [net.ipv4.tcp_max_syn_backlog]=16384
    [net.ipv4.tcp_max_tw_buckets]=32768
    [net.ipv4.tcp_fin_timeout]=60
    [net.ipv4.tcp_keepalive_time]=7200
    [net.ipv4.tcp_keepalive_probes]=9
    [net.ipv4.tcp_keepalive_intvl]=75
    [net.ipv4.tcp_tw_reuse]=1
    [net.ipv4.neigh.default.gc_thresh1]=4096
    [net.ipv4.neigh.default.gc_thresh2]=8192
    [net.ipv4.neigh.default.gc_thresh3]=16384

    # iptables
    [net.netfilter.nf_conntrack_max]=131072
    [net.netfilter.nf_conntrack_buckets]=65536

    # kernel
    [kernel.threads-max]=55601
    [kernel.panic]=3

    # virtual memory
    [vm.max_map_count]=65530
    [vm.vfs_cache_pressure]=100
    [vm.swappiness]=60
)
# always wipe out 99-custom.conf
echo "" > /etc/sysctl.d/99-custom.conf
for key in ${!tweaks[@]}; do
    echo "${key}=${tweaks[${key}]}" >> /etc/sysctl.d/99-custom.conf
done
# enable THP
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo madvise > /sys/kernel/mm/transparent_hugepage/defrag

# load all tweaks now and on subsequent boots
systemctl restart procps

# install k3s
export http_proxy="https://proxy.dmz.ava.local:3128"
export https_proxy="https://proxy.dmz.ava.local:3128"
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest INSTALL_K3S_EXEC='server --cluster-init' sh -
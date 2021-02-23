############# CRI-O #############

cat <<EOF | tee /etc/modules-load.d/cri-o.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

##

. /etc/lsb-release
OS='x'$DISTRIB_ID'_'$DISTRIB_RELEASE
VERSION=${crio_version}

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > "/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list"

curl -L "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key" | apt-key add -
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key" | apt-key add -

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y cri-o cri-o-runc cri-tools

sed -i 's|conmon = ""|conmon = "/usr/bin/conmon"|g' /etc/crio/crio.conf

systemctl enable cri-o.service
systemctl start cri-o.service
systemctl status cri-o.service

crictl info

# kubelet to use cri-o
# Remember the space at the start
MODULE_KUBELET_EXTRA_ARGS=' --container-runtime remote --cgroup-driver=systemd --container-runtime-endpoint unix:///var/run/crio/crio.sock --runtime-request-timeout=5m'

systemctl daemon-reload
systemctl restart kubelet

echo 'KUBELET_EXTRA_ARGS=--cloud-provider=aws'"$MODULE_KUBELET_EXTRA_ARGS" > /etc/default/kubelet

############# CRI-O #############

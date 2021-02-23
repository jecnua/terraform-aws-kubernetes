############# CONTAINERD #############

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

cat <<EOF | tee /etc/modules-load.d/containerd.conf
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

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update
apt-get install -y containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Now we need to add the shim to use also gvisor
# https://gvisor.dev/docs/user_guide/install/
(
  set -e
  ARCH=$(uname -m)
  URL=https://storage.googleapis.com/gvisor/releases/release/latest/$ARCH
  wget $URL/runsc $URL/runsc.sha512 \
    $URL/containerd-shim-runsc-v1 $URL/containerd-shim-runsc-v1.sha512
  sha512sum -c runsc.sha512 \
    -c containerd-shim-runsc-v1.sha512
  rm -f *.sha512
  chmod a+rx runsc containerd-shim-runsc-v1
  mv runsc containerd-shim-runsc-v1 /usr/local/bin
)

# Configure the toml
# https://gvisor.dev/docs/user_guide/containerd/quick_start/
cat <<CRIEOF | tee /etc/containerd/config.toml
disabled_plugins = ["restart"]
[plugins.linux]
  shim_debug = true
[plugins.cri.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
CRIEOF

# Install crictl
# https://gvisor.dev/docs/user_guide/containerd/quick_start/
CRICTL_VERSION="v1.20.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz

# crictl use containerd as default
cat <<CRIEOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
CRIEOF

systemctl restart containerd

# kubelet to use containerd
# Remember the space at the start
MODULE_KUBELET_EXTRA_ARGS=' --container-runtime remote --container-runtime-endpoint unix:///run/containerd/containerd.sock'

systemctl daemon-reload
systemctl restart kubelet

echo 'KUBELET_EXTRA_ARGS=--cloud-provider=aws'$MODULE_KUBELET_EXTRA_ARGS > /etc/default/kubelet

############# CONTAINERD #############
############# DOCKER #############

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

apt install -y \
  docker.io

## Configure docker deamon
# From https://kubernetes.io/docs/setup/production-environment/container-runtimes/
# Solves [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd".
cat > /etc/docker/daemon.json <<CRIEOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
CRIEOF
systemctl daemon-reload
systemctl restart docker
# Avoids [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
systemctl enable docker.service
# Adding user on docker group
usermod -aG docker ubuntu

echo 'KUBELET_EXTRA_ARGS=--cloud-provider=aws' > /etc/default/kubelet

############# DOCKER #############
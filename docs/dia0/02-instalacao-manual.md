# Instalação Manual do Ambiente

## Go

### Instalação

- Baixar última versão:

```bash
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)
wget "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
```

- Instalar:

```bash
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz"
```

- Configurar ambiente:

```bash
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc
```

## Docker

### Dependências

- Atualizar sistema:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

- Adicionar chave GPG:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

- Configurar repositório:

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Instalação

- Instalar pacotes:

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

- Configurar usuário:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Kind e Registry Local

### Kind

- Instalação:

```bash
go install sigs.k8s.io/kind@latest
```

### Registry Local

- Criar container:

```bash
docker run -d --name kind-registry -p 5001:5000 --restart=always registry:2
```

- Criar cluster com registry:

```bash
cat << EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
  - containerPort: 30443
    hostPort: 8443
EOF

kind create cluster --name k8s-operators-lab --config kind-config.yaml
```

## Ferramentas de Desenvolvimento

### Kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Kubebuilder

```bash
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder
sudo mv kubebuilder /usr/local/bin/
```

### Kustomize

```bash
KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | jq -r .tag_name)
VERSION_NUMBER=${KUSTOMIZE_VERSION#kustomize/}
curl -L -o kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${VERSION_NUMBER}/kustomize_${VERSION_NUMBER}_linux_amd64.tar.gz"
tar xzf kustomize.tar.gz
sudo mv kustomize /usr/local/bin/
```

### Tilt

```bash
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
```

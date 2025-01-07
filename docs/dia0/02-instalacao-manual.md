# Instalação Manual do Ambiente

## Go

1. Baixar última versão:

```bash
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)
wget "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
```

2. Instalar:

```bash
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz"
```

3. Configurar ambiente:

```bash
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc
```

## Docker

1. Instalar dependências:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

2. Adicionar repositório:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

3. Instalar Docker:

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

4. Configurar usuário:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Kind e Registry Local

1. Instalar Kind:

```bash
go install sigs.k8s.io/kind@latest
```

2. Criar registry local:

```bash
docker run -d --name kind-registry -p 5001:5000 --restart=always registry:2
```

3. Criar cluster com registry:

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

1. Kubectl:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

2. Kubebuilder:

```bash
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder
sudo mv kubebuilder /usr/local/bin/
```

3. Kustomize:

```bash
KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | jq -r .tag_name)
VERSION_NUMBER=${KUSTOMIZE_VERSION#kustomize/}
curl -L -o kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${VERSION_NUMBER}/kustomize_${VERSION_NUMBER}_linux_amd64.tar.gz"
tar xzf kustomize.tar.gz
sudo mv kustomize /usr/local/bin/
```

4. Tilt:

```bash
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
```

## Validação

Verificar instalações:

```bash
go version
docker --version
kind version
kubectl version --client
kubebuilder version
kustomize version --short
tilt version
```

## Considerações de Segurança

1. Acesso root necessário para:
   - Instalação de pacotes
   - Configuração do Docker
   - Configuração de binários em /usr/local/bin

2. Portas utilizadas:
   - 5001: Registry local
   - 8080: Ingress HTTP
   - 8443: Ingress HTTPS
   - 6443: API Kubernetes

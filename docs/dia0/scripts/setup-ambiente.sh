#!/bin/bash

set -euo pipefail

# Cores para logging
readonly VERMELHO='\033[0;31m'
readonly VERDE='\033[0;32m' 
readonly AMARELO='\033[1;33m'
readonly AZUL='\033[0;34m'
readonly NC='\033[0m'

# Configurações
readonly REG_NAME='kind-registry'
readonly REG_PORT='5001'
readonly CLUSTER_NAME='k8s-operators-lab'
readonly GO_VERSION="$(curl -s https://go.dev/VERSION?m=text)"

log() {
    local nivel=$1
    local msg=$2
    local cor=""
    case $nivel in
        "INFO") cor=$AZUL ;;
        "SUCESSO") cor=$VERDE ;;
        "AVISO") cor=$AMARELO ;;
        "ERRO") cor=$VERMELHO ;;
    esac
    echo -e "${cor}[$(date +'%Y-%m-%d %H:%M:%S')] [$nivel]${NC} $msg"
}

comando_existe() {
    command -v "$1" >/dev/null 2>&1
}

confirmar() {
    read -r -p "$1 [s/N] " response
    case "$response" in
        [sS][iI][mM]|[sS]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

instalar_go() {
    if ! comando_existe go; then
        log "INFO" "Instalando Go ${GO_VERSION}..."
        local arquivo="${GO_VERSION}.linux-amd64.tar.gz"
        wget "https://go.dev/dl/${arquivo}" -O "/tmp/${arquivo}"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "/tmp/${arquivo}"
        rm "/tmp/${arquivo}"
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.profile"
        echo 'export GOPATH=$HOME/go' >> "$HOME/.profile"
        echo 'export PATH=$PATH:$GOPATH/bin' >> "$HOME/.profile"
        source "$HOME/.profile"
        log "SUCESSO" "Go instalado: $(go version)"
    else
        log "INFO" "Go já instalado: $(go version)"
    fi
}

instalar_docker() {
    if ! comando_existe docker; then
        log "INFO" "Instalando Docker..."
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo usermod -aG docker "$USER"
        log "SUCESSO" "Docker instalado: $(docker --version)"
        log "AVISO" "Faça logout e login para usar Docker sem sudo"
    else
        log "INFO" "Docker já instalado: $(docker --version)"
    fi
}

configurar_registry() {
    log "INFO" "Configurando registry local..."
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${REG_NAME}$"; then
        if confirmar "Registry existente encontrado. Deseja recriar?"; then
            docker rm -f "${REG_NAME}"
        else
            log "INFO" "Mantendo registry existente"
            return
        fi
    fi

    docker run -d \
        --name "${REG_NAME}" \
        --restart=always \
        -p "127.0.0.1:${REG_PORT}:5000" \
        registry:2

    log "SUCESSO" "Registry local configurado"
}

criar_cluster() {
    log "INFO" "Criando cluster Kind..."

    if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
        if confirmar "Cluster ${CLUSTER_NAME} já existe. Recriar?"; then
            kind delete cluster --name "${CLUSTER_NAME}"
        else
            log "INFO" "Mantendo cluster existente"
            return
        fi
    fi

    cat << EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
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
    protocol: TCP
  - containerPort: 30443
    hostPort: 8443
    protocol: TCP
- role: worker
- role: worker
EOF

    log "SUCESSO" "Cluster Kind criado"
}

configurar_registry_nodes() {
    log "INFO" "Configurando registry nos nodes..."
    
    local registry_dir="/etc/containerd/certs.d/localhost:${REG_PORT}"
    for node in $(kind get nodes --name "${CLUSTER_NAME}"); do
        docker exec "${node}" mkdir -p "${registry_dir}"
        cat << EOF | docker exec -i "${node}" cp /dev/stdin "${registry_dir}/hosts.toml"
[host."http://${REG_NAME}:5000"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
EOF
    done

    if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${REG_NAME}")" = 'null' ]; then
        docker network connect "kind" "${REG_NAME}"
    fi

    log "SUCESSO" "Registry configurado nos nodes"
}

instalar_kubectl() {
    if ! comando_existe kubectl; then
        log "INFO" "Instalando kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        log "SUCESSO" "Kubectl instalado: $(kubectl version --client)"
    else
        log "INFO" "Kubectl já instalado: $(kubectl version --client)"
    fi
}

instalar_kind() {
    if ! comando_existe kind; then
        log "INFO" "Instalando Kind..."
        GO111MODULE="on" go install sigs.k8s.io/kind@latest
        log "SUCESSO" "Kind instalado: $(kind --version)"
    else
        log "INFO" "Kind já instalado: $(kind --version)"
    fi
}

instalar_kubebuilder() {
    if ! comando_existe kubebuilder; then
        log "INFO" "Instalando Kubebuilder..."
        curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
        chmod +x kubebuilder
        sudo mv kubebuilder /usr/local/bin/
        log "SUCESSO" "Kubebuilder instalado: $(kubebuilder version)"
    else
        log "INFO" "Kubebuilder já instalado: $(kubebuilder version)"
    fi
}

instalar_kustomize() {
    if ! comando_existe kustomize; then
        log "INFO" "Instalando Kustomize..."
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/
        log "SUCESSO" "Kustomize instalado: $(kustomize version)"
    else
        log "INFO" "Kustomize já instalado: $(kustomize version)"
    fi
}

instalar_tilt() {
    if ! comando_existe tilt; then
        log "INFO" "Instalando Tilt..."
        curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
        log "SUCESSO" "Tilt instalado: $(tilt version)"
    else
        log "INFO" "Tilt já instalado: $(tilt version)"
    fi
}

main() {
    log "INFO" "Iniciando setup do ambiente de desenvolvimento..."

    # Verificar sudo
    if ! comando_existe sudo; then
        log "ERRO" "sudo não encontrado. Instale com: apt-get install sudo"
        exit 1
    fi

    # Update do sistema
    log "INFO" "Atualizando sistema..."
    sudo apt-get update -y
    sudo apt-get install -y curl wget git make gcc jq

    # Instalação de ferramentas
    instalar_go
    instalar_docker
    instalar_kind
    instalar_kubectl
    instalar_kubebuilder
    instalar_kustomize
    instalar_tilt

    # Setup do ambiente k8s
    configurar_registry
    criar_cluster
    configurar_registry_nodes

    # Configurar registry no cluster
    cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REG_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

    log "SUCESSO" "Ambiente configurado com sucesso!"
    log "INFO" "Execute 'source ~/.profile' para atualizar variáveis de ambiente"
}

main "$@"
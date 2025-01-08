#!/bin/bash

set -euo pipefail

readonly VERMELHO='\033[0;31m'
readonly VERDE='\033[0;32m'
readonly AMARELO='\033[1;33m'
readonly NC='\033[0m'

get_version() {
    local cmd=$1
    case $cmd in
        "go") go version 2>&1 ;;
        "docker") docker version --format '{{.Server.Version}}' 2>&1 ;;
        "kind") kind --version 2>&1 ;;
        "kubectl") kubectl version --client --output=yaml | grep -i gitversion | head -n1 | cut -d: -f2- ;;
        "kubebuilder") kubebuilder version | head -n1 2>&1 ;;
        "kustomize") kustomize version --short 2>&1 | head -n1 ;;
        "tilt") tilt version | head -n1 2>&1 ;;
        *) echo "Comando desconhecido" ;;
    esac
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${VERDE}✓${NC} $1 instalado: $(get_version "$1")"
        return 0
    else
        echo -e "${VERMELHO}✗${NC} $1 não encontrado"
        return 1
    fi
}

check_docker() {
    if docker run hello-world >/dev/null 2>&1; then
        echo -e "${VERDE}✓${NC} Docker funcionando corretamente"
        return 0
    else
        echo -e "${VERMELHO}✗${NC} Erro ao executar container Docker"
        return 1
    fi
}

check_registry() {
    if curl -s localhost:5001/v2/_catalog >/dev/null 2>&1; then
        echo -e "${VERDE}✓${NC} Registry local respondendo"
        return 0
    else
        echo -e "${VERMELHO}✗${NC} Registry local não acessível"
        return 1
    fi
}

check_kubernetes() {
    if kubectl cluster-info >/dev/null 2>&1; then
        echo -e "${VERDE}✓${NC} Cluster Kubernetes respondendo"
        
        local nodes
        nodes=$(kubectl get nodes -o name)
        if [ -n "$nodes" ]; then
            echo -e "${VERDE}✓${NC} Nodes encontrados: "
            echo "$nodes"
        else
            echo -e "${VERMELHO}✗${NC} Nenhum node encontrado"
            return 1
        fi
        
        return 0
    else
        echo -e "${VERMELHO}✗${NC} Cluster Kubernetes não acessível"
        return 1
    fi
}

test_operator() {
    local temp_dir
    temp_dir=$(mktemp -d)
    pushd "$temp_dir" >/dev/null

    echo -e "\n${AMARELO}Testando criação de operator...${NC}"
    
    kubebuilder init --domain example.com --repo example.com/test >/dev/null 2>&1
    kubebuilder create api --group apps --version v1alpha1 --kind Test --resource --controller >/dev/null 2>&1
    
    if make manifests generate >/dev/null 2>&1; then
        echo -e "${VERDE}✓${NC} Build operator sucesso"
    else
        echo -e "${VERMELHO}✗${NC} Falha no build do operator"
    fi

    popd >/dev/null
    rm -rf "$temp_dir"
}

main() {
    echo -e "${AMARELO}Iniciando validação do ambiente...${NC}\n"

    check_command go
    check_command docker
    check_command kind
    check_command kubectl
    check_command kubebuilder
    check_command kustomize
    check_command tilt

    echo -e "\n${AMARELO}Validando ambiente Docker...${NC}"
    check_docker
    check_registry

    echo -e "\n${AMARELO}Validando cluster Kubernetes...${NC}"
    check_kubernetes

    test_operator

    echo -e "\n${VERDE}Validação concluída!${NC}"
}

main "$@"
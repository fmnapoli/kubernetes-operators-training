# Dia 0 - Preparação do Ambiente

## Visão Geral

Para desenvolver Operators Kubernetes precisamos de um ambiente completo que inclui:

- Linguagem de programação (Go)
- Container runtime (Docker)
- Cluster Kubernetes local (Kind)
- Registry local para imagens
- Ferramentas de desenvolvimento

## Requisitos de Hardware

- CPU: 4+ cores
- RAM: 8GB+
- Disco: 20GB+ livre
- Sistema: Ubuntu/Debian

## Componentes do Ambiente

### Go Toolchain

- Compilador Go
- Ferramentas de teste e build
- GOPATH configurado

### Container Runtime

- Docker Engine
- Acesso ao Docker Hub
- Grupo docker configurado

### Kubernetes Local

- Kind (Kubernetes in Docker)
- Registry local integrado
- Kubectl CLI

### Ferramentas de Desenvolvimento

- Kubebuilder: Framework para operators
- Kustomize: Gerenciamento de configuração K8s
- Tilt: Hot reload para desenvolvimento

## Próximos Passos

1. [Instalação Manual](dia0/01-instalacao-manual.md)
2. [Script Automatizado](dia0/02-script-automacao.md)
3. [Validação do Ambiente](dia0/03-validacao.md)
4. [Troubleshooting](dia0/04-troubleshooting.md)

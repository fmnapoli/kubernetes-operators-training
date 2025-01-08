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

1. [Instalação Manual](02-instalacao-manual.md)
2. [Script Automatizado](03-script-automacao.md)
3. [Validação do Ambiente](04-validacao.md)

## Verificação da Instalação

Para validar se o ambiente foi configurado corretamente, utilize os scripts fornecidos na pasta `scripts/`:

- `setup-ambiente.sh`: Instala e configura todos os componentes
- `validate-env.sh`: Valida a instalação e funcionamento do ambiente

## Problemas Comuns

Caso encontre problemas durante a instalação:

1. Verifique os logs de erro
2. Consulte a documentação oficial de cada ferramenta
3. Verifique permissões de usuário
4. Valide requisitos de sistema

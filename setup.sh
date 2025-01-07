#!/bin/bash

# Criar estrutura para dia 0
mkdir -p docs/dia0/{scripts,assets}

# Criar arquivos principais
touch docs/dia0/{01-introducao,02-instalacao-manual,03-script-automacao,04-validacao}.md

# Criar scripts
cat > docs/dia0/scripts/setup-ambiente.sh << 'EOL'
# Script será criado em seguida
EOL

cat > docs/dia0/scripts/validate-env.sh << 'EOL'
# Script será criado em seguida
EOL

# Tornar scripts executáveis
chmod +x docs/dia0/scripts/*.sh

# Atualizar mkdocs.yml
cat > mkdocs.yml << 'EOL'
site_name: Treinamento Kubernetes Operators com Go
site_description: Treinamento self-paced para desenvolvimento de Operators Kubernetes com Go
site_author: Fabrizio Malta Di Napoli
repo_url: https://github.com/fmnapoli/kubernetes-operators-training

theme:
  name: material
  language: pt-BR
  features:
    - navigation.sections
    - content.code.copy

markdown_extensions:
  - pymdownx.highlight
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - admonition
  - pymdownx.details

plugins:
  - search
  - mermaid2

nav:
  - Home: index.md
  - Dia 0 - Setup:
    - Introdução: dia0/01-introducao.md
    - Instalação Manual: dia0/02-instalacao-manual.md
    - Script de Automação: dia0/03-script-automacao.md
    - Validação: dia0/04-validacao.md
  - Dia 1:
    - Introdução: dia1/01-introducao.md
    - API Kubernetes: dia1/02-api-kubernetes.md
    - Prática: dia1/03-pratica.md
extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/fmnapoli
    - icon: fontawesome/brands/linkedin
      link: https://linkedin.com/in/fabrizio-napoli    
EOL

echo "Estrutura criada com sucesso"
# API Kubernetes

## Fluxo de Comunicação

```mermaid
sequenceDiagram
    participant U as Usuario
    participant A as API Server
    participant E as etcd
    participant C as Controller
    
    U->>A: Create Resource
    A->>E: Save Resource
    E-->>A: Confirm
    A-->>U: Resource Created
    A->>C: Resource Changed
    C->>A: Update Status
    A->>E: Save Status
```

## Estrutura da API

```mermaid
graph TD
    A[API Kubernetes] --> B[Groups]
    B --> C1[core]
    B --> C2[apps]
    B --> C3[batch]
    
    C1 --> D1[v1]
    C2 --> D2[v1]
    C2 --> D3[v1beta1]
    
    D1 --> E1[pods]
    D1 --> E2[services]
    D2 --> E3[deployments]
    D2 --> E4[statefulsets]
```

A API Kubernetes é organizada em:

1. **Groups**: Conjuntos lógicos de recursos
   - core (v1)
   - apps
   - batch
   - networking.k8s.io

2. **Versions**: Níveis de estabilidade
   - v1: estável
   - v1beta1: beta
   - v1alpha1: alpha

3. **Resources**: Tipos de objetos
   - pods
   - deployments
   - services
   - configmaps

### URLs da API

Formato padrão:

```bash
/apis/{group}/{version}/namespaces/{namespace}/{resource}
```

Exemplos:

- `/api/v1/namespaces/default/pods`
- `/apis/apps/v1/namespaces/default/deployments`
- `/apis/networking.k8s.io/v1/namespaces/default/ingresses`

# Prática com a API Kubernetes

## Interagindo com a API

### Usando kubectl proxy

```bash
# Inicia o proxy
kubectl proxy --port=8080

# Em outro terminal
export API_URL=http://localhost:8080
```

### Listando Recursos

```bash
# Via curl
curl $API_URL/api/v1/namespaces/default/pods

# Equivalente kubectl
kubectl get pods -n default
```

### Criando Recursos

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

```bash
# Via curl
curl -X POST $API_URL/api/v1/namespaces/default/pods \
  -H "Content-Type: application/yaml" \
  --data-binary @pod.yaml

# Equivalente kubectl
kubectl apply -f pod.yaml
```

### Obtendo Detalhes

```bash
# Via curl
curl $API_URL/api/v1/namespaces/default/pods/nginx

# Equivalente kubectl
kubectl get pod nginx -o yaml
```

### Deletando Recursos

```bash
# Via curl
curl -X DELETE $API_URL/api/v1/namespaces/default/pods/nginx

# Equivalente kubectl
kubectl delete pod nginx
```

## Exercícios

1. Configure o ambiente:
   - Instale kubectl
   - Configure acesso a um cluster (minikube/kind)
   - Teste conectividade

2. Crie recursos básicos:
   - Pod com Nginx
   - Deployment com 3 réplicas
   - Service expondo o deployment

3. Pratique debugging:
   - Use kubectl describe
   - Verifique logs
   - Examine eventos

4. Faça chamadas API diretas:
   - Liste pods via API
   - Crie um deployment via API
   - Delete recursos via API

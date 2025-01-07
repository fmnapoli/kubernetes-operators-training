# Validação do Ambiente

## Testes de Componentes

### 1. Go

```bash
# Verificar versão
go version

# Testar compilação
cat << EOF > hello.go
package main
import "fmt"
func main() {
    fmt.Println("Hello, Kubernetes Operators!")
}
EOF
go build hello.go
./hello
```

### 2. Docker

```bash
# Verificar serviço
systemctl status docker

# Testar permissões
docker run hello-world

# Validar registry local
docker pull nginx
docker tag nginx localhost:5001/test
docker push localhost:5001/test
```

### 3. Kubernetes

```bash
# Verificar cluster
kubectl cluster-info
kubectl get nodes

# Testar pod
kubectl run test --image=nginx
kubectl get pods

# Verificar registry no cluster
kubectl create deployment test --image=localhost:5001/test
kubectl get deployments
```

### 4. Ferramentas

```bash
# Kubebuilder
kubebuilder version

# Criar projeto teste
mkdir operator-test && cd operator-test
kubebuilder init --domain example.com
kubebuilder create api --group apps --version v1 --kind Test

# Kustomize
kustomize version
kustomize build config/default/

# Tilt
tilt version
```

## Checklist de Validação

1. Ambiente Go:
   - [ ] GOPATH configurado
   - [ ] Compilação funcionando
   - [ ] Módulos GO111MODULE

2. Container Runtime:
   - [ ] Docker rodando
   - [ ] Permissões corretas
   - [ ] Registry acessível

3. Cluster Kubernetes:
   - [ ] Nodes healthy
   - [ ] API respondendo
   - [ ] Registry integrado

4. Ferramentas Dev:
   - [ ] Kubebuilder funcionando
   - [ ] Kustomize processando
   - [ ] Tilt disponível

## Teste Integrado

Criar operator mínimo:

```bash
# Setup
mkdir test-operator && cd test-operator
go mod init test-operator
kubebuilder init --domain example.com

# API
kubebuilder create api --group apps --version v1alpha1 --kind Test

# Build
make manifests
make generate
make docker-build IMG=localhost:5001/test-operator:v1

# Deploy
make deploy IMG=localhost:5001/test-operator:v1
```

Verificar:

```bash
kubectl get pods -n test-operator-system
kubectl logs -n test-operator-system -l control-plane=controller-manager
```

## Métricas de Saúde

1. Recursos do Cluster:

```bash
kubectl top nodes
kubectl top pods -A
```

2. Registry Local:

```bash
curl http://localhost:5001/v2/_catalog
```

3. Logs do Sistema:

```bash
journalctl -u docker
kubectl logs -n kube-system -l k8s-app=kube-apiserver
```

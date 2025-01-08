# Validação do Ambiente

## Testes de Componentes

### Go

- Verificar versão:

```bash
go version
```

- Testar compilação:

```bash
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

### Docker

- Verificar serviço:

```bash
systemctl status docker
```

- Testar permissões:

```bash
docker run hello-world
```

- Validar registry local:

```bash
docker pull nginx
docker tag nginx localhost:5001/test
docker push localhost:5001/test
```

### Kubernetes

- Verificar cluster:

```bash
kubectl cluster-info
kubectl get nodes
```

- Testar pod:

```bash
kubectl run test --image=nginx
kubectl get pods
```

- Verificar registry no cluster:

```bash
kubectl create deployment test --image=localhost:5001/test
kubectl get deployments
```

### Ferramentas de Desenvolvimento

- Kubebuilder:

```bash
kubebuilder version
```

- Testar criação de projeto:

```bash
mkdir operator-test && cd operator-test
kubebuilder init --domain example.com
kubebuilder create api --group apps --version v1 --kind Test
```

- Kustomize:

```bash
kustomize version
kustomize build config/default/
```

- Tilt:

```bash
tilt version
```

## Checklist de Validação

### Ambiente Go

- [ ] GOPATH configurado
- [ ] Compilação funcionando
- [ ] Módulos GO111MODULE

### Container Runtime

- [ ] Docker rodando
- [ ] Permissões corretas
- [ ] Registry acessível

### Cluster Kubernetes

- [ ] Nodes healthy
- [ ] API respondendo
- [ ] Registry integrado

### Ferramentas Dev

- [ ] Kubebuilder funcionando
- [ ] Kustomize processando
- [ ] Tilt disponível

## Teste Integrado

### Setup

```bash
mkdir test-operator && cd test-operator
go mod init test-operator
kubebuilder init --domain example.com
```

### API

```bash
kubebuilder create api --group apps --version v1alpha1 --kind Test
```

### Build e Deploy

```bash
make manifests
make generate
make docker-build IMG=localhost:5001/test-operator:v1
make deploy IMG=localhost:5001/test-operator:v1
```

### Verificação

```bash
kubectl get pods -n test-operator-system
kubectl logs -n test-operator-system -l control-plane=controller-manager
```

## Métricas de Saúde

### Recursos do Cluster

```bash
kubectl top nodes
kubectl top pods -A
```

### Registry Local

```bash
curl http://localhost:5001/v2/_catalog
```

### Logs do Sistema

```bash
journalctl -u docker
kubectl logs -n kube-system -l k8s-app=kube-apiserver
```

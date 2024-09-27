sudo systemctl start docker
k3d cluster start mycluster


check the nodes

kubectl get nodes 

kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl port-forward svc/wil-playground-service -n dev 8888:8888
argocd login localhost:8080
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
xN7gDEABtsyYiqrR

argocd app get wil-playground


argocd app sync wil-playground
argocd app set wil-playground --path configs

argocd app sync wil-playground
argocd app get wil-playground


kubectl run curl-test --image=radial/busyboxplus:curl -i --tty --rm
curl wil-playground-service.dev.svc.cluster.local:8888


curl http://172.18.0.2:30000/


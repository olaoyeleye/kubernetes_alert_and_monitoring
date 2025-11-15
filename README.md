terraform fmt -recursive
terraform init -upgrade
terraform validate
terraform apply -auto-approve -var 'region=us-east-1'




aws eks update-kubeconfig --region eu-west-2 --name monitoring-eks
kubectl get nodes



kubectl apply -f nginx.yaml
kubectl apply -f redis.yaml
kubectl apply -f busybox.yaml


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

kubectl get pods -n monitoring
kubectl get svc -n monitoring

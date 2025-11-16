
cd eks_folder/monitoring_and_alerting

terraform fmt -recursive
terraform init -upgrade
terraform validate

terraform apply --auto-approve \
-target=module.vpc \
-target=module.eks

scp -i "C:/Users/USER/Downloads/Ore_infra-key.pem" -r ec2-user@16.171.32.151:/home/ec2-user/eks_folder/monitoring_and_alerting .


scp -i "C:/Users/USER/Downloads/Ore_infra-key.pem" -r monitoring_and_alerting ec2-user@16.171.32.151:eks_folder


# Navigate to the parent directory of your project folder
Check the permissions on the destination directory on your EC2 instance:

ssh ec2-user@your-ec2-host
ls -ld /home/ec2-user/eks_folder
ls -ld /home/ec2-user/eks_folder/monitoring_and_alerting


# If the directories don’t exist or are owned by another user or root, fix it:
# Create directory (if missing):
mkdir -p /home/ec2-user/eks_folder/monitoring_and_alerting
# Set ownership to your ec2-user:
sudo chown -R ec2-user:ec2-user /home/ec2-user/eks_folder
# Set write permissions:
chmod -R u+rw /home/ec2-user/eks_folder
# Then retry your scp command.
sudo chown -R ec2-user:ec2-user /home/ec2-user/eks_folder
chmod -R u+rw /home/ec2-user/eks_folder

terraform apply -auto-approve 

terraform apply --auto-approve -target=module.vpc -target=module.eks
terraform apply --auto-approve -target=module.helm


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

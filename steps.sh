# Create k8s cluster in kind
kind create cluster --name traefik-hub-demo

AGENT_TOKEN="<YOUR_AGENT_TOKEN>"

# Add Traefik proxy Helm repository
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

# Install Traefik proxy
helm upgrade --install traefik traefik/traefik \
--namespace hub-agent --create-namespace \
--set=additionalArguments='{--experimental.hub,--hub}' \
--set metrics.prometheus.addRoutersLabels=true \
--set providers.kubernetesIngress.allowExternalNameServices=true \
--set ports.web=null --set ports.websecure=null --set ports.metrics.expose=true \
--set ports.traefikhub-tunl.port=9901 --set ports.traefikhub-tunl.expose=true --set ports.traefikhub-tunl.exposedPort=9901 --set ports.traefikhub-tunl.protocol="TCP" \
--set service.type="ClusterIP" --set fullnameOverride=traefik-hub 

# Add Traefik hub Helm repository
helm repo add traefik-hub https://helm.traefik.io/hub
helm repo update

# Install Traefik hub-agent
helm upgrade --install hub-agent traefik-hub/hub-agent \
--set token=$AGENT_TOKEN --namespace hub-agent \
--create-namespace --set image.pullPolicy=Always --set image.tag=experimental

# Deploy Tour of heroes demo
k create ns tour-of-heroes
k apply -f tour-of-heroes -n tour-of-heroes --recursive

# Wait for resources to be ready
watch kubectl get all -n tour-of-heroes
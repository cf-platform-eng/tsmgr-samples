### Metrics Example

* Bootstrap Helm
* Install ingress-controller
* Install Influxdb helm chart
* Install Grafana helm chart
* Setup on LoadBalancer to receive data


#### Bootstrap Helm

```bash
gcloud container clusters get-credentials <my-cluster> --zone=us-central1-a --project=<my-project>

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

helm init --upgrade --service-account tiller
```

#### Install Ingress Controller

```bash
helm install ~/workspace/charts/stable/nginx-ingress
```

```bash
kubectl get services | grep nginx
```

Configure DNS to point to nginx's external IP address

#### Install Influx

```bash
helm install ~/workspace/charts/stable/influxdb \ 
    --set config.auth_enabled=true \
    --set setDefaultUser.enabled=true \
    --set setDefaultUser.user.password=<password> \
    --set ingress.enabled=true \
    --set ingress.hostname=influxdb.monitoring.example.com
```

#### Install Grafana

```bash
helm install ~/workspace/charts/stable/grafana \
    --set service.type=LoadBalancer \
    --set adminPassword=<password> \
    --set ingress.enabled=true \
    --set hosts="[grafana.monitoring.example.com]"
```

#### Testing metrics

See https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/

```bash
export url=http://influxdb.monitoring.example.com
curl -i -XPOST ${url}/query --data-urlencode "q=DROP DATABASE manual"
curl -i -XPOST ${url}/query --data-urlencode "q=CREATE DATABASE manual"

while true; do
    curl -i -XPOST "${url}/write?db=manual" --data-binary "cpu_load_short,host=server01 value=$(python -c 'import random; print(random.random())')"
    sleep 5
done
```


#### Delete

```bash
kubectl --namespace=<kibosh-xxx> exec -it <k-XXX-rabbitmq-0>  -c rabbitmq -- /bin/sh -c "kill 1"
```


#### Notes

* https://www.datadoghq.com/blog/rabbitmq-monitoring/

### Metrics Example
#### Introduction

This offering deploys RabbitMQ with prometheus operator for a service team to monitor the instances. The offering
consists of three parts:
* The [open source RabbitMQ chart](https://github.com/helm/charts/tree/master/stable/rabbitmq)
* The [open source Prometheus operator chart](https://github.com/helm/charts/tree/master/stable/prometheus-operator)
* Custom code [exporter](exporter/) that scrapes the Prometheus endpoint and ships it to InfluxDB

![](docs/metrics.png)
 
See [MySQL](../mysql) for a more detailed walkthrough; this example builds on prior understanding
of KSM learned from working with MySQL chart.

The offering, once deployed, reports out to an external InfluxDB and Grafana.
The following steps show how to bootstrap these components into a fresh cluster via Helm.

The custom `exporter.py` code could report to any external solution, SaaS or an on premise product. We
chose InfluxDB and Grafana arbitrarily. 

### Prerequisites
* PCF environment with KSM installed and configured.
* ksm cli


### Setup

The following steps are outlined below:
* Bootstrap Helm
* Install ingress-controller and configure DNS
* Install InfluxDB helm chart
* Install Grafana helm chart

#### Bootstrap Helm

This solution uses Helm to setup the off-platform metrics sink. See
the [Helm docs](https://helm.sh/) for a detailed explaination of this tool.

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

To make InfluxDB and Grafana accessible to the workloads we're deploying (which will be in a different cluster),
install an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

```bash
helm install ~/workspace/charts/stable/nginx-ingress
```

```bash
kubectl get services | grep nginx
```

And then configure DNS to point to nginx's external IP address.

#### Install InfluxDB

The following overrides a few of the chart's default values using `--set`

```bash
helm install ~/workspace/charts/stable/influxdb \ 
    --set config.auth_enabled=true \
    --set setDefaultUser.enabled=true \
    --set setDefaultUser.user.password=<password> \
    --set ingress.enabled=true \
    --set ingress.hostname=influxdb.monitoring.example.com
```

#### Install Grafana

The following overrides a few of the chart's default values using `--set`

```bash
helm install ~/workspace/charts/stable/grafana \
    --set service.type=LoadBalancer \
    --set adminPassword=<password> \
    --set ingress.enabled=true \
    --set hosts="[grafana.monitoring.example.com]"
```

#### Testing Setup

To test that InfluxDB is working, `curl` can be used to send data.
See the [Influx docs](https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/)
for more details. 

```bash
export url=http://influxdb.monitoring.example.com
curl -i -XPOST ${url}/query --data-urlencode "q=DROP DATABASE manual"
curl -i -XPOST ${url}/query --data-urlencode "q=CREATE DATABASE manual"

while true; do
    curl -i -XPOST "${url}/write?db=manual" --data-binary "cpu_load_short,host=server01 value=$(python -c 'import random; print(random.random())')"
    sleep 5
done
```

## KSM

### Build the Exporter

[The exporter](exporter) includes a docker image and the shim that exports to the metrics sink.
The example uses the image from our registry, so there's no need to build the image. To fully view
how the demo works, take a look at [exporter.py](exporter/exporter.py) to see how
it's building, tagging, and pushing that image.  

### Offer RabbitMQ to CF marketplace

The package script downloads Helm dependencies and does a `helm package` so the charts can be offered. It takes
the custom exporter chart and adds it as a subschart of Rabbit.

```bash
./package.sh
ksm offer save ksm.yaml prometheus-operator-6.8.1.tgz rabbitmq-6.4.4.tgz
ksm offer list
```

Enable service access

```bash
cf enable-service-access rabbitmq-with-external-monitoring
cf marketplace
```

Create RabbitMQ instance
```bash
cf create-service rabbitmq-with-external-monitoring default my-rabbit
```

Once Rabbit comes up, the exporter will start reporting to InfluxDB.

#### Demo

To see the metrics in action, import sample graph from [status_dashboard.json](docs/status_dashboard.json) 

To bring rabbitMQ down and see something interesting in the graph:

```bash
kubectl --namespace=<kibosh-xxx> exec -it <k-XXX-rabbitmq-0>  -c rabbitmq -- /bin/sh -c "kill 1"
```

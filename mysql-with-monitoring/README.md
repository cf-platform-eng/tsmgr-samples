# Tanzu Service Manager MySQL + Prometheus

This example uses MySQL from 
[bitnami](https://github.com/bitnami/charts/tree/master/bitnami/mysql)
and Prometheus from 
[prometheus-community/helm-charts](https://github.com/prometheus-community/helm-charts).

This is a multi-chart offering that show's how Tanzu Service Manager can easily
add a monitoring component to an existing MySQL Helm chart. Tanzu Service Manager can
compose multiple chart components without requiring modification to those components.

* The Prometheus overrides file primarily turns off most features to reduce resource consumption as it's 
  run through our CI system (we also override the image as CI uses a private registry server).
* The MySQL chart overrides file add a load balancer, sets the default db, and turns off
  additional features to reduce resource usage.

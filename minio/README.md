# Tanzu Service Manager with Minio

This example uses the [Bitnami Minio Chart](https://github.com/bitnami/charts/tree/master/bitnami/minio)
to provision an instance.

The `overrides.yaml` file changes the service type to add a load-balancer, as the default
chart uses ClusterIP. This example also demonstrates templating the values file to set the 
default bucket to the name of the release. 


#### Chart Notes

For the root user's password, this chart by default uses Helm's `randAlphaNum` helper for the password.
This means that any upgrade or other change that re-deploys the chart will result
in a password change, and thus require binding the service instance again. To mitigate this and
control when the password changes at the end user level, use
`create-service` configuration parameters:

```bash
cf create-service minio default my-minio -c '{"accessKey": {"password": "some-secure-string"}}'
```

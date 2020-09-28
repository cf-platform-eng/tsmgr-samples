# Tanzu Service Manager with Redis

This example uses the [Bitnami Redis Chart](https://github.com/bitnami/charts/tree/master/bitnami/redis)
to provision an instance.

The `override-redis.yaml` file changes the service type to add a load-balancer, as the default
chart uses ClusterIP.

#### Chart Notes

For the root user's password, this chart by default uses Helm's `randAlphaNum` helper for the password.
This means that any upgrade or other change that re-deploys the chart will result
in a password change, and thus require binding the service instance again. To mitigate this and
control when the password changes at the end user level, use
`create-service` configuration parameters:

```bash
cf create-service redis default my-redis -c '{"password": "some-secure-string"}'
```

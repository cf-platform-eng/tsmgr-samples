# CoreOS etcd-operator

[etcd-operator](https://coreos.com/blog/introducing-the-etcd-operator.html) Simplify etcd cluster
configuration and management.

__DISCLAIMER:__ While this chart has been well-tested, the etcd-operator is still currently in beta.
Current project status is available [here](https://github.com/coreos/etcd-operator).

## Introduction

This chart bootstraps an etcd-operator and allows the deployment of etcd-cluster(s).

## Official Documentation

Official project documentation found [here](https://github.com/coreos/etcd-operator)

API reference [here](https://github.com/etcd-io/etcd/blob/master/Documentation/v2/api.md)

## Prerequisites

- PCF environment with KSM installed and configured.
- __Suggested:__ PV provisioner support in the underlying infrastructure to support backups
- ksm cli referred below is an alias configured to  `$KSM_PATH/ksm.darwin "$@" -k -t $KSM_SERVER -u $KSM_USER -p $KSM_PASSWORD`. 
If you want to create the same alias for your environment, add the following function to your .bash_profile, .profile or .bashrc files:

``` 
export KSM_PATH=<The path where your ksm.darwin is located>
export KSM_SERVER=http://<change_by_your_ksm_server>:<change_by_your_ksm_server_port>
export KSM_USER=<change_by_your_ksm_user>
export KSM_PASSWORD=<change_by_your_ksm_password>

ksm ()
{
    if [ -n "$ZSH_VERSION" ]; then
        emulate -L sh;
    fi;
    if [ "$1" == "" ]; then
        $KSM_PATH/ksm.darwin --help;
    else
        $KSM_PATH/ksm.darwin "$@" -k -t $KSM_SERVER -u $KSM_USER -p $KSM_PASSWORD;
    fi
}
```


## Publishing the Marketplace Offer

To publish the marketplace offer:

<pre><b>$ ksm offer save etcd-operator/etcd-operator-0.8.3.tgz</b></pre>

The command publishes etcd-operator offer on PCF in the default configuration. The marketplace name and version will match the name and version defined in Chart.yaml file.

Alternatively a &lt;ksm&gt;.yaml file can be defined in the ksm directory with a different marketplace name and used as input for `ksm offer save`:

__etcd-operator/ksm/custom-etcd.yaml__ sample
```
marketplace-name: custom-etcd
charts:
  - chart: etcd-operator
    offered: true
    scope: namespace
    version: 0.8.3
```

<pre><b>$ ksm offer save etcd-operator/ksm etcd-operator/etcd-operator-0.8.3.tgz
</b></pre>

The current offers can be listed as following:

<pre>
<b>$ ksm offer list</b>
MARKETPLACE NAME	INCLUDED CHARTS	VERSION	PLANS
etcd-operator   	etcd-operator  	0.8.3  	[default]

</pre>

## Enabling CF access 

The marketplace offer access is not available by default via cf command. You can verify that by calling the follow commands. 
Notice that etcd-operator is not available at marketplace, even though it is listed by service-access (with access=none):

<pre>
<b>$ cf marketplace</b>
Getting services from marketplace in org ksm-dev / space dev as admin...
OK
service               plans                                                  description                                                                                                                                                                                                                           broker

<b>$ cf service-access</b>
Getting service access as admin...
broker: kubernetes-service-manager
   service    plan      access   orgs
<b>   etcd-operator      default    none</b>
</pre>

In order to enable the access, use the following command:

<pre>
<b>$ cf enable-service-access etcd-operator</b>
Enabling access to all plans of service etcd-operator for all orgs as admin...
OK

<b>$ cf marketplace</b>
Getting services from marketplace in org ksm-dev / space dev as admin...
OK

service         plans     description                                      broker<b>
etcd-operator   default   CoreOS etcd-operator Helm chart for Kubernetes   container-services-manager</b>
</pre>
 
## Creating an instance

After enabling access to the markeplace offer, it's possible to provision a new instance.

First let's list the cf and kubernetes services:
<pre>
<b>$ cf services</b>
Getting services in org ksm-dev / space dev as admin...

No services found
</pre>

Now, let's create and list a new instance. 

<pre>
<b>$ cf create-service etcd-operator default etcdopersvc</b> 

<b>$ cf services</b>
Getting services in org ksm-dev / space dev as admin...

name            service         plan    bound apps  last operation      broker<b>
etcdopersvc     etcd-operator   default             create succeeded    container-services-manager</b>
</pre>

## Accessing / using etcd-operator service

In order to access / use the service just created we can do the following:

<b>- Create a service key for the etcd-operator instance:
</b>
<pre>
<b>$ cf create-service-key ectdopersvc ectdopersvc-key</b>
</pre>
<b>- Look for the cluster load balancer IP (loadBalancer/ingress/ip) address and port (ports/port):</b>
<pre>
<b>$ cf service-key etcdopersvc etcdopersvc-key</b>
Getting key etcdopersvc-key for service instance etcdopersvc as admin...

  ...
  "name": "etcd-cluster-lb",
   "spec": {
    "clusterIP": "10.100.200.46",
    "externalTrafficPolicy": "Cluster",
    "ports": [
     {
      "name": "etcd-cluster-port",
      "nodePort": 32360,
      <b>"port": 2379,</b>
      "protocol": "TCP",
      "targetPort": 2379
     }
    ],
    "selector": {
     "etcd_cluster": "etcd-cluster"
    },
    "sessionAffinity": "None",
    "type": "LoadBalancer"
   },
   "status": {
    "loadBalancer": {
     "ingress": [
      {
       <b>"ip": "&lt;some_public_ip>"</b>
      }
     ]
    }
   }
  },
  ...
</pre>

<b>
- See the etcd-operator version (remove "|jq" if you don't have jq program available. It is only to pretty print the JSON response)</b>
<pre>
$ curl http://some_public_ip:2379/version 2>/dev/null |jq
{
    "etcdserver": "3.2.25",
    "etcdcluster": "3.2.0"
}</pre><b>
- See the etc-operator members:</b>
<pre>
$ curl http://some_public_ip:2379/v2/members 2>/dev/null |jq
{
  "members": [
    {
      "id": "61918693241c2465",
      "name": "etcd-cluster-9w99vzcn22",
      "peerURLs": [
        "http://etcd-cluster-9w99vzcn22.etcd-cluster.kibosh-394a20b1-9735-4a94-b67a-40f3765f002f.svc:2380"
      ],
      "clientURLs": [
        "http://etcd-cluster-9w99vzcn22.etcd-cluster.kibosh-394a20b1-9735-4a94-b67a-40f3765f002f.svc:2379"
      ]
    },
    {
      "id": "87b303e8adf32068",
      "name": "etcd-cluster-jkfzjtkx69",
      "peerURLs": [
        "http://etcd-cluster-jkfzjtkx69.etcd-cluster.kibosh-394a20b1-9735-4a94-b67a-40f3765f002f.svc:2380"
      ],
      "clientURLs": [
        "http://etcd-cluster-jkfzjtkx69.etcd-cluster.kibosh-394a20b1-9735-4a94-b67a-40f3765f002f.svc:2379"
      ]
    },
    {
      "id": "aa1b3cd000cd1f3b",
      "name": "etcd-cluster-b2v7ml4rrs",
      "peerURLs": [
        "http://etcd-cluster-b2v7ml4rrs.etcd-cluster.kibosh-394a20b1-9735-4a94-b67a-40f3765f002f.svc:2380"
      ],
      "clientURLs": [
        "http://etcd-cluster-b2v7ml4rrs.etcd-cluster.kibosh-394a20b1-9735-4a94-b67a-40f3765f002f.svc:2379"
      ]
    }
  ]
}</pre><b>
- Verify that no keys are stored in the etc-operator</b>
<pre>
$ curl http://some_public_ip:2379/v2/keys/ 2>/dev/null |jq
{
  "action": "get",
  "node": {
    "dir": true
  }
}
</pre><b>
- Add a new key value to etc-operator and verify it is stored</b>
<pre>
$ curl -X PUT http://34.69.48.131:2379/v2/keys/customer-name -d value=MyCustomer 2>/dev/null |jq
{
  "action": "set",
  "node": {
    "key": "/customer-name",
    "value": "MyCustomer",
    "modifiedIndex": 18,
    "createdIndex": 18
  }
}
</pre>
<pre>
$ curl http://some_public_ip:2379/v2/keys/ 2>/dev/null |jq
{
  "action": "get",
  "node": {
    "dir": true,
    "nodes": [
      {
        "key": "/customer-name",
        "value": "MyCustomer",
        "modifiedIndex": 14,
        "createdIndex": 14
      }
    ]
  }
}
</pre><b>OR</b>
<pre>
$ curl http://some_public_ip:2379/v2/keys/customer-name 2>/dev/null |jq
{
  "action": "get",
  "node": {
    "key": "/customer-name",
    "value": "MyCustomer",
    "modifiedIndex": 14,
    "createdIndex": 14
  }
}
</pre><b>
- Delete the created key</b>
<pre>
$ curl -X DELETE http://some_public_ip:2379/v2/keys/customer-name 2>/dev/null|jq
{
  "action": "delete",
  "node": {
    "key": "/customer-name",
    "modifiedIndex": 17,
    "createdIndex": 16
  },
  "prevNode": {
    "key": "/customer-name",
    "value": "MyCustomer",
    "modifiedIndex": 16,
    "createdIndex": 16
  }
}
</pre><pre>
$ curl http://some_public_ip:2379/v2/keys/ 2>/dev/null |jq
{
  "action": "get",
  "node": {
    "dir": true
  }
}
</pre>

## Deleting the marketplace offer

To remove the marketplace offer:

<pre>
<b>ksm offer delete etcd-operator</b>
</pre>

## Other External References

For more details and customizations for etcd-operator chart, see https://github.com/helm/charts/tree/master/stable/etcd-operator

For more details on ksm usage see http://to-do-link

For other Pivotal documents see https://docs.pivotal.io/

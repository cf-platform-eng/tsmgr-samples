# MySQL

[MySQL](https://MySQL.org) is one of the most popular database servers in the world. Notable users include Wikipedia, Facebook and Google.

## Introduction

This chart bootstraps a single node MySQL deployment on a PCF (Pivotal Cloud Foundry).

## Prerequisites

- PCF environment


## Publishing the Marketplace Offer

To publish the marketplace offer:

<pre><b>$ ksm offer save mysql-1.3.0.tgz</b></pre>

The command publishes MySQL offer on PCF in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during 
installation. The marketplace name and version will match the name and version defined in Chart.yaml file.

Alternatively a <ksm>.yaml file can be defined with a different marketplace name and use that as input for `ksm offer save`:

__custom-mysql.yaml__ sample
```
marketplace-name: custom-mysql
charts:
  - chart: mysql
    offered: true
    scope: namespace
```

<pre><b>$ ksm offer save custom-mysql.yaml mysql-1.3.0.tgz
</b></pre>

The current offers can be listed as following:

<pre>
<b>$ ksm offer list</b>
DEBU[0000] Making request to https://ksm.sys.brea.cf-app.com/offers
MARKETPLACE NAME	INCLUDED CHARTS	VERSION	PLANS
dokuwiki        	dokuwiki       	5.1.2  	[default]
mysql           	mysql          	1.3.0  	[medium small]
</pre>

## Enabling CF access 

The marketplace offer access is not available by default via cf command. You can verify that by calling the follow commands. 
Notice that mysql is not available at marketplace, even though it is listed by service-access (with access=none):

<pre>
<b>$ cf marketplace</b>
Getting services from marketplace in org ksm-dev / space dev as admin...
OK
service               plans                                                  description                                                                                                                                                                                                                           broker
contrast-security     contrast-test, aws, test-plan-jharper, APPTWO COPPER   Provide Contrast credentials to an application                                                                                                                                                                                        contrast-security-service-broker
aerospike-on-demand   small, medium, large                                   An enterprise-class NoSQL database providing speed at scale                                                                                                                                                                           aerospike-odb
dokuwiki              default                                                DokuWiki is a standards-compliant, simple to use wiki optimized for creating documentation. It is targeted at developer teams, workgroups, and small companies. All data is stored in plain text files, so no database is required.   kubernetes-service-manager

<b>$ cf service-access</b>
Getting service access as admin...
broker: kubernetes-service-manager
   service    plan      access   orgs
   dokuwiki   default   all
<b>   mysql      medium    none
   mysql      small     none</b>
</pre>

In order to enable the access, use the following command:

<pre>
<b>$ cf enable-service-access mysql</b>
Enabling access to all plans of service mysql for all orgs as admin...
OK

<b>$ cf marketplace</b>
Getting services from marketplace in org ksm-dev / space dev as admin...
OK

service               plans                                                  description                                                                                                                                                                                                                           broker
contrast-security     contrast-test, aws, test-plan-jharper, APPTWO COPPER   Provide Contrast credentials to an application                                                                                                                                                                                        contrast-security-service-broker
aerospike-on-demand   small, medium, large                                   An enterprise-class NoSQL database providing speed at scale                                                                                                                                                                           aerospike-odb
dokuwiki              default                                                DokuWiki is a standards-compliant, simple to use wiki optimized for creating documentation. It is targeted at developer teams, workgroups, and small companies. All data is stored in plain text files, so no database is required.   kubernetes-service-manager
<b>mysql                 small, medium                                          Fast, reliable, scalable, and easy to use open-source relational database system.                                                                                                                                                     kubernetes-service-manager</b>
</pre>
 
## Creating an instance

After enabling access to the markeplace offer, it's possible to provision a new instance.

First let's list the cf and kubernetes services:
<pre>
<b>$ cf services</b>
Getting services in org ksm-dev / space dev as admin...

No services found

<b>$ k get services -A</b>
NAMESPACE     NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
default       kubernetes             ClusterIP   10.100.200.1     <none>        443/TCP         25d
kibosh        tiller-deploy          ClusterIP   10.100.200.229   <none>        44134/TCP       23h
kube-system   kube-dns               ClusterIP   10.100.200.2     <none>        53/UDP,53/TCP   29d
kube-system   kubernetes-dashboard   NodePort    10.100.200.250   <none>        443:30689/TCP   29d
kube-system   metrics-server         ClusterIP   10.100.200.189   <none>        443/TCP         29d
kube-system   tiller-deploy          ClusterIP   10.100.200.73    <none>        44134/TCP       25d
pks-system    fluent-bit             ClusterIP   10.100.200.151   <none>        24224/TCP       29d
pks-system    validator              ClusterIP   10.100.200.103   <none>        443/TCP         29d
</pre>

Now, let's create a new instance. We can also list the new cf and kubernetes services

<pre>
<b>$ cf create-service mysql small mysql1</b> 

<b>$ cf services</b>
Getting services in org ksm-dev / space dev as admin...

name     service   plan    bound apps   last operation       broker
<b>mysql1   mysql     small                create in progress   kubernetes-service-manager</b>

<b>$ k get services -A</b>
NAMESPACE                                     NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)          AGE
default                                       kubernetes             ClusterIP      10.100.200.1     <none>           443/TCP          25d
<b>kibosh-7f4bca5e-ab88-4194-af58-fef5f00360a8   k-y6id2qob-mysql       LoadBalancer   10.100.200.61    35.226.253.233   3306:31628/TCP   7m6s</b>
kibosh                                        tiller-deploy          ClusterIP      10.100.200.229   <none>           44134/TCP        23h
kube-system                                   kube-dns               ClusterIP      10.100.200.2     <none>           53/UDP,53/TCP    29d
kube-system                                   kubernetes-dashboard   NodePort       10.100.200.250   <none>           443:30689/TCP    29d
kube-system                                   metrics-server         ClusterIP      10.100.200.189   <none>           443/TCP          29d
kube-system                                   tiller-deploy          ClusterIP      10.100.200.73    <none>           44134/TCP        25d
pks-system                                    fluent-bit             ClusterIP      10.100.200.151   <none>           24224/TCP        29d
pks-system                                    validator              ClusterIP      10.100.200.103   <none>           443/TCP          29d
</pre>

> ***Tip***: List the instances guid for the marketplace name as following. Notice it matches the kubernetes namespace:

<pre>
<b>$ ksm instance list mysql</b>
DEBU[0000] Making request to https://ksm.sys.brea.cf-app.com/instances/mysql
INSTANCE GUID                       	VERSION	CREATION
7f4bca5e-ab88-4194-af58-fef5f00360a8	1.3.0  	2019-09-04 20:56:45 +0000 UTC
</pre>

## Retrieving the Mysql password / Connecting to the Database


By default a random password will be generated for the root user. If you'd like to set your own password change the mysqlRootPassword
in the values.yaml.

You can retrieve your root password by running the following command and connect to the mysql database (if you have mysql client):

<pre>
<b>$ kubectl get secret --namespace=kibosh-7f4bca5e-ab88-4194-af58-fef5f00360a8 k-y6id2qob-mysql -o jsonpath='{.data.mysql-root-password}'|base64 -D</b>
DZnryW7frq

# Get the pod name
<b>$ k get pods -A|grep k-y6id2qob-mysql</b>
kibosh-7f4bca5e-ab88-4194-af58-fef5f00360a8   k-y6id2qob-mysql-dcbd7b6c6-6jbrt        1/1     Running     0          68m

# Connect to the pod
<b>k exec --namespace=kibosh-7f4bca5e-ab88-4194-af58-fef5f00360a8 -it k-y6id2qob-mysql-dcbd7b6c6-6jbrt /bin/bash</b>

# Connect to the mysql database
<b>root@k-y6id2qob-mysql-dcbd7b6c6-6jbrt:/# mysql -u root -p</b>
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 898
Server version: 5.7.27 MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

<b>mysql> select sysdate();</b>
+---------------------+
| sysdate()           |
+---------------------+
| 2019-09-04 22:09:44 |
+---------------------+
1 row in set (0.00 sec)
</pre>

__It is also possible to connect from your local computer to the database using the external IP, if you have mysql cli or other client:__
<pre>
<b>$ mysql -u root -p -h 35.226.253.233</b>
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 709
Server version: 5.7.27 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
<b>mysql> select sysdate();</b>
+---------------------+
| sysdate()           |
+---------------------+
| 2019-09-04 21:54:12 |
+---------------------+
1 row in set (0.05 sec)
</pre>

## Deleting the marketplace offer

To remove the marketplace offer:

<pre>
<b>ksm offer delete mysql</b>
</pre>


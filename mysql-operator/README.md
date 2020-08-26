# MySQL Operator

[MySQL](https://MySQL.org) is one of the most popular database servers in the world. Notable users include Wikipedia, Facebook and Google.

## Introduction

This example includes a Helm chart for the Presslabs MySQL Operator, and a Helm chart for a MySQL Cluster instance.

## Prerequisites

- TAS environment with KSM installed and configured.
- Connection setup for the `ksm` CLI to properly target an environment

``` 
export KSM_TARGET=http://<change_by_your_ksm_server>:<change_by_your_ksm_server_port>
export KSM_USER=<change_by_your_ksm_user>
export KSM_PASSWORD=<change_by_your_ksm_password>
export KSM_INSECURE=true # if using a lab environment
```

- Kubernetes [cluster registered with KSM](https://docs.pivotal.io/ksm/managing-clusters.html) and set as default
```bash
ksm cluster register my-cluster-name my-cluster-creds-file.yaml
ksm cluster set-default my-cluster-name
```

## Patterns for Offering Operators in KSM

1) You can install (and upgrade) the operator manually into each cluster before offering the instance Helm chart in KSM.
    The operator must be configured to watch all namespaces in this approach. 
    ```bash
    helm install mysql-operator mysql-operator
    ```
    In this case, the offer `ksm.yaml` only needs to include the `mysql-cluster` instance Helm chart:
    ```
    marketplace-name: mysql-instance-only
    charts:
      - chart: mysql-cluster
        version: 0.2.0
        offered: true
        scope: namespace
    ```
    To offer the instance Helm chart:
    ```bash
    ksm offer save ksm/ mysql-cluster-0.2.0.tgz
    ```
   
1) (Recommended) You can offer both the `mysql-operator` and `mysql-cluster` Helm charts with KSM. 
This is recommended because the Platform Operator does not need to manually install the `mysql-operator` Helm chart
into each cluster where Developers may provision `mysql-cluster` instances. 
    
    You can offer the `mysql-operator` chart as either `Namespace` scoped or `Cluster` scoped. 
    
    `Namespace` scoped means the `mysql-operator` chart will be installed in every namespace along with the `mysql-cluster` instance.
    
    ```yaml
    marketplace-name: mysql-operator
    charts:
      - chart: mysql-operator
        version: 0.1.1+master
        offered: false
        scope: namespace
      - chart: mysql-cluster
        version: 0.2.0
        offered: true
        scope: namespace
    ```
   
     `Cluster` scoped means the `mysql-operator` chart will be installed once in the cluster and watch all namespaces.

    ```yaml
    marketplace-name: mysql-operator
    charts:
      - chart: mysql-operator
        version: 0.1.1+master
        offered: false
        scope: cluster
      - chart: mysql-cluster
        version: 0.2.0
        offered: true
        scope: namespace
    ```
   
    The instructions below follow the `Cluster` scoped pattern. 

## Saving the Marketplace Offer

To save the marketplace offer:

```bash
$ ksm offer save ksm mysql-operator-0.1.1+master.tgz mysql-cluster-0.2.0.tgz
```

The command saves MySQL Operator offer on TAS. The marketplace name and version will match the name and version defined in `ksm.yaml` file.

The current offers can be listed as following:
<pre>
<b>$ ksm offer list</b>
MARKETPLACE NAME	INCLUDED CHARTS	VERSION	        PLANS
mysql-operator  	mysql-cluster  	0.2.0       	[default]
-               	mysql-operator 	0.1.1+master
</pre>

## Enabling CF access 

The marketplace offer access is not available by default via cf command. You can verify that by calling the follow commands. 
Notice that mysql is not available in the marketplace, even though it is listed by service-access (with access=none):

```bash
$ cf marketplace
Getting services from marketplace in org ksm-dev / space dev as admin...
OK
service               plans                                                  description   

$ cf service-access
Getting service access as admin...
broker: tanzu-service-manager
   service          plan      access   orgs
   mysql-operator   default   none
```

In order to enable the access, use the following command:
```bash
$ cf enable-service-access mysql-operator
Enabling access to all plans of service mysql-operator for all orgs as admin...
OK

$ cf marketplace
Getting services from marketplace in org system / space dev as admin...
OK

service          plans     description                                                                         broker
mysql-operator   default   A Helm chart for easy deployment of a MySQL cluster with MySQL operator.            tanzu-service-manager
```
 
## Creating an instance

After enabling access to the marketplace offer, it's possible to provision a new instance.

First let's list the cf and kubernetes services:
```bash
$ cf services
Getting services in org ksm-dev / space dev as admin...

No services found
```

Now, let's create a new instance. We can also list the new cf and kubernetes services
```bash
$ cf create-service mysql-operator default mysql-op1
Creating service instance mysql-op1 in org system / space dev as admin...
OK

Create in progress. Use 'cf services' or 'cf service mysql-op1' to check operation status.

$ cf services
Getting services in org system / space dev as admin...

name             service          plan      bound apps   last operation     broker                       upgrade available
mysql-op1        mysql-operator   default                create succeeded   tanzu-service-manager   no
```

## Binding an app to mysql instance 

Please follow the instructions at https://github.com/cloudfoundry-samples/spring-music to build, deploy and bind the 
spring-music app to mysql database.
 
You should visualize the binding details in spring-music app after binding process as following:

![After binding](../mysql/app-sample/after-binding.png)

## [Optional] See the data in MySQL instance

__Pre requisite:__ You must have mysql cli to execute this step!

You can verify the app data in MySQL instance as optional step. 
To do that:

- Create a service key for the MySQL instance:

<pre>
<b>$ cf create-service-key mysql-op1 mysql-servicekey</b>
</pre>

- Verify the hostname, user and password in the service key data

<pre>
<b>$ cf service-key mysql-op1 mysql-servicekey</b>
Getting key mysql-servicekey for service instance mysql-op as admin...

{
 "hostname": "10.10.11.11",
 "jdbcUrl": "jdbc:mysql://34.67.50.44/mydb?user=root\u0026password=root\u0026useSSL=false",
 "name": "k-ftwbah22-mysql-cluster-db",
 "password": "root",
 "port": 3306,
 "uri": "mysql://root:root@34.67.50.44:3306/mydb?reconnect=true",
 "username": "root"
}
</pre>

- Connect to the MySQL database:

```bash
$ mysql -u root -p -h <hostname></b>
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 17700
Server version: 5.7.27 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

- Select the mydb database:
<pre>
<b>mysql> use mydb;</b>
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
</pre>

- List the album table:
<pre>
<b>mysql> select * from album;</b>
+--------------------------------------+----------+---------------------------+-------+--------------+----------------------------+-------------+
| id                                   | album_id | artist                    | genre | release_year | title                      | track_count |
+--------------------------------------+----------+---------------------------+-------+--------------+----------------------------+-------------+
| 7cb1bacc-9115-476b-b31b-d33ef2ef073f | NULL     | Nirvana                   | Rock  | 1991         | Nevermind                  |           0 |
| e08bba9b-2202-4db0-ada8-1c49e49ee3e9 | NULL     | The Beach Boys            | Rock  | 1966         | Pet Sounds                 |           0 |
| 3e32e4f8-1cfd-467e-97a8-b57aaaef1fea | NULL     | Marvin Gaye               | Rock  | 1971         | What's Going On            |           0 |
| 3358ed51-d08e-4b76-a00c-35ab8e72194b | NULL     | Jimi Hendrix Experience   | Rock  | 1967         | Are You Experienced?       |           0 |
| b0332035-0ef5-48a6-bb4d-c8c1f261e9d3 | NULL     | U2                        | Rock  | 1987         | The Joshua Tree            |           0 |
| 73f2f2d8-8e6d-49ae-97f8-1542e5792f71 | NULL     | The Beatles               | Rock  | 1969         | Abbey Road                 |           0 |
| f2716d6e-9c8e-4851-b57f-4704bb9bdc8a | NULL     | Fleetwood Mac             | Rock  | 1977         | Rumours                    |           0 |
| b18a57e7-9473-4a67-8cb3-4be5169f4a13 | NULL     | Elvis Presley             | Rock  | 1976         | Sun Sessions               |           0 |
| c68a0bcb-cdf7-499d-8fee-026c8c535bd4 | NULL     | Michael Jackson           | Pop   | 1982         | Thriller                   |           0 |
| 0127d800-78e9-41fc-90bf-ca15d92efaa6 | NULL     | The Rolling Stones        | Rock  | 1972         | Exile on Main Street       |           0 |
| 8dfc90f4-25b4-4cc2-bf76-c080eecb78c8 | NULL     | Bruce Springsteen         | Rock  | 1975         | Born to Run                |           0 |
| 1cad4352-9cba-4fb7-bdc5-a1783e4d7bd9 | NULL     | The Clash                 | Rock  | 1980         | London Calling             |           0 |
| 3a2da1b2-ec89-414e-a91e-8d8d3ae1d6cd | NULL     | The Eagles                | Rock  | 1976         | Hotel California           |           0 |
| a6c599f6-fb6d-444a-9249-de604a420c83 | NULL     | Led Zeppelin              | Rock  | 1969         | Led Zeppelin               |           0 |
| 8b3999ad-0fe2-4e6a-b4ff-c603e272431d | NULL     | Led Zeppelin              | Rock  | 1971         | IV                         |           0 |
| 41909630-f6cf-4de9-941e-72f0b37a6a0f | NULL     | Police                    | Rock  | 1983         | Synchronicity              |           0 |
| d5326122-988c-47ec-92ca-cea81ef1516a | NULL     | U2                        | Rock  | 1991         | Achtung Baby               |           0 |
| 7988342a-a82b-4705-9de2-14e849acac3b | NULL     | The Rolling Stones        | Rock  | 1969         | Let it Bleed               |           0 |
| 0d8d4f10-be71-4dae-9c94-45bf612c0a68 | NULL     | The Beatles               | Rock  | 1965         | Rubber Soul                |           0 |
| d058c4d4-b636-4fd8-bea5-9dfedbd73ff2 | NULL     | The Ramones               | Rock  | 1976         | The Ramones                |           0 |
| d6d04449-8068-43a6-8d75-367f450facb2 | NULL     | Queen                     | Rock  | 1975         | A Night At The Opera       |           0 |
| a3ab1206-28a2-44a7-8bb8-1f3a2eb49c93 | NULL     | Boston                    | Rock  | 1978         | Don't Look Back            |           0 |
| f5b854b6-c7b3-4634-bdb5-5e016d1ad2a0 | NULL     | BB King                   | Blues | 1956         | Singin' The Blues          |           0 |
| 69f35571-d4df-425c-b385-9ee6aed47f12 | NULL     | Albert King               | Blues | 1967         | Born Under A Bad Sign      |           0 |
| 936e0e5a-46ae-46ea-bacf-f37f687f8666 | NULL     | Muddy Waters              | Blues | 1964         | Folk Singer                |           0 |
| bcf23d32-ec36-44b9-a112-a70f373ba741 | NULL     | The Fabulous Thunderbirds | Blues | 1979         | Rock With Me               |           0 |
| 9065c4bf-b41b-4954-93d3-8fc19463626f | NULL     | Robert Johnson            | Blues | 1961         | King of the Delta Blues    |           0 |
| 10ad4bc7-4ea0-428c-808f-aa718f8af2d9 | NULL     | Stevie Ray Vaughan        | Blues | 1983         | Texas Flood                |           0 |
| 1da1d56b-f073-4e39-9e72-d9c52ed8711d | NULL     | Stevie Ray Vaughan        | Blues | 1984         | Couldn't Stand The Weather |           0 |
+--------------------------------------+----------+---------------------------+-------+--------------+----------------------------+-------------+
29 rows in set (0.05 sec)
</pre>

## Deleting the marketplace offer

To remove the marketplace offer:

<pre>
<b>ksm offer delete mysql</b>
</pre>

## External References

For more details and customizations for MySQL chart, see https://github.com/helm/charts/tree/master/stable/mysql

For more details on ksm usage see http://to-do-link

For other Pivotal documents see https://docs.pivotal.io/


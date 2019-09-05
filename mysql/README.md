# MySQL

[MySQL](https://MySQL.org) is one of the most popular database servers in the world. Notable users include Wikipedia, Facebook and Google.

## Introduction

This chart bootstraps a single node MySQL deployment on a PCF (Pivotal Cloud Foundry).

## Prerequisites

- PCF environment
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

<pre><b>$ ksm offer save mysql-1.3.0.tgz</b></pre>

The command publishes MySQL offer on PCF in the default configuration. The marketplace name and version will match the name and version defined in Chart.yaml file.

Alternatively a &lt;ksm&gt;.yaml file can be defined with a different marketplace name and used as input for `ksm offer save`:

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

Now, let's create a new instance. We can also list the new cf and kubernetes services

<pre>
<b>$ cf create-service mysql small mysql1</b> 

<b>$ cf services</b>
Getting services in org ksm-dev / space dev as admin...

name     service   plan    bound apps   last operation       broker
<b>mysql1   mysql     small                create in progress   kubernetes-service-manager</b>
</pre>

## Binding an app to mysql instance / Connecting to the Database

Now lets deploy an app to CF and bind that to the new MySQL instance. 

- Create a temporary folder anywhere in your computer, for example:
`mkdir ~/mytempfolder`
- Download the spring-music [app sample](./app-sample/spring-music-app.tgz) to the temporary folder you just created
- Execute the following commands to decompress and deploy the app:
```bash
$ tar xvzf spring-music-app.tgz
$ cf push
```
- Execute the following command to verify the app http endpoint, and visualize that in the browser
<pre>
<b>$ cf app spring-music</b>
Showing health and status for app spring-music in org ksm-dev / space dev as admin...

name:              spring-music
requested state:   started
<b>routes:            spring-music-interested-badger.apps.brea.cf-app.com</b>
last uploaded:     Thu 05 Sep 15:34:57 CDT 2019
stack:             cflinuxfs3
buildpacks:        client-certificate-mapper=1.8.0_RELEASE
                   container-security-provider=1.16.0_RELEASE
                   java-buildpack=v4.18-offline-https://github.com/cloudfoundry/java-buildpack.git#a0df7d0
                   java-main java-opts java-security
                   jvmkill-agent=1.16.0_RELEASE open-jdk-...

type:           web
instances:      1/1
memory usage:   1024M
     state     since                  cpu    memory         disk           details
#0   running   2019-09-05T20:35:29Z   0.4%   219.8M of 1G   173.1M of 1G
</pre>

![Before binding](./app-sample/before-binding.png)

Let's bind this app to the MySQL database instance and restage the app:

<pre>
<b>$ cf bind-service spring-music mysql1</b>
Binding service mysql1 to app spring-music in org ksm-dev / space dev as admin...
OK

TIP: Use 'cf restage spring-music' to ensure your env variable changes take effect

<b>$ cf restage spring-music</b>
This action will cause app downtime.

Restaging app spring-music in org ksm-dev / space dev as admin...

Staging app and tracing logs...
   Downloading nodejs-buildpack-jharper...
   .
   .
   .
   Cell 34a86296-cf9e-4c2f-a839-14f67f9cd306 successfully destroyed container for instance 3738070a-d9f0-4193-a15c-b0221af7f1f3

Waiting for app to start...

name:              spring-music
requested state:   started
routes:            spring-music-interested-badger.<?>.cf-app.com
last uploaded:     Thu 05 Sep 16:05:54 CDT 2019
stack:             cflinuxfs3
buildpacks:        client-certificate-mapper=1.8.0_RELEASE container-security-provider=1.16.0_RELEASE
                   java-buildpack=v4.18-offline-https://github.com/cloudfoundry/java-buildpack.git#a0df7d0 java-main java-opts java-security
                   jvmkill-agent=1.16.0_RELEASE open-jdk-...

type:            web
instances:       1/1
memory usage:    1024M
start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR
                 -XX:ActiveProcessorCount=$(nproc)
                 -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                 -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" &&
                 CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT
                 -loadedClasses=20868 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration:
                 $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                 $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.JarLauncher
     state     since                  cpu      memory       disk           details
#0   running   2019-09-05T21:06:24Z   120.1%   151M of 1G   173.1M of 1G
</pre>

Now we can see the app using MySQL:

![After binding](./app-sample/after-binding.png)

## [Optional] See the data in MySQL instance

__Pre requisite:__ You must have mysql cli to execute this step!

You can verify the app data in MySQL instance as optional step. 
To do that:

- Create a service key for the MySQL instance:

<pre>
<b>$ cf create-service-key mysql1 mysql1-servicekey</b>
</pre>

- Verify the hostname, user and password in the service key data

<pre>
<b>$ cf service-key mysql1 mysql1-servicekey</b>
Getting key mysql1-servicekey for service instance mysql1 as admin...

{
 "hostname": "some_ip_address",
 "jdbcUrl": "jdbc:mysql://some_ip_address/my_db?user=root\u0026password=some_password\u0026useSSL=false",
 "name": "k-y6id2qob-mysql",
 "password": "some_password",
 "port": 3306,
 "uri": "mysql://root:some_password@some_ip_address:3306/my_db?reconnect=true",
 "username": "root"
}
</pre>

- Connect to the MySQL database:

<pre>
<b>$ mysql -u root -p -h some_ip_address</b>
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 17700
Server version: 5.7.27 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
</pre>

- Select the my_db database:
<pre>
<b>mysql> use my_db;</b>
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
# tsmgr-samples
Tanzu Service Manager Sample Charts

This project contains samples for using Tanzu Service Manager (TSMGR) for Tanzu. 
For details on Tanzu Service Manager installation and configuration, refer to the following document:

[Tanzu Service Manager Documentation](https://docs.pivotal.io/tanzu-service-manager)

## Contents
* bitnami-posgresql Single chart example including a binding template and override examples
* ci-charts (Internal Usage) Charts used for testing the TSMGR product in CI, and **will not work for other public** since it refers to non-public repositories
* minio Single chart example including a plan and override examples
* [mysql-operator](mysql-operator) Example of an operator managed database
  - This example also describes [Patterns for Offering Operators in Tanzu Service Manager](./mysql-operator#patterns-for-offering-operators-in-tsmgr)
* mysql-with-monitoring Example that shows how to combine two charts (mysql + prometheus), includes a binding template
override values for both mysql and prometheus, and two plans
* [mysql](mysql) Example of a single node MySQL deployment offered


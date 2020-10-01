# tsmgr-samples

This project contains example Offers for use with Tanzu Service Manager (TSMGR).

For information on how to install and configure Tanzu Service Manager, please refer to the [official documentation](https://docs.pivotal.io/tanzu-service-manager).

**NB**: The samples presented here are for demonstration purposes only and as such are not officially supported.

## Contents

Following is a description of each of the sample Offers, along with two "feature check lists" for each:

**TSMGR feauture check list**: Features in this list are configured by modifying the TSMGR `*.yaml` files (`tsmgr.yaml`, `plans.yaml`, etc...).

**Service feature check list**: Features in this list are configured in the underlying Helm chart.

* ✅  = the feature is included and being demonstrated in the corresponding Offer
* ❌  = the feature is not configured in the corresponding Offer
* 🤔  = unknown if the feature is supported or not

### [bitnami-posgresql](/bitnami-posgresql) 

**Description**: A basic Offer comprised of the Bitnami postgresql helm chart.

**TSMGR feauture check list**:
  * (Recommended) Adheres to the `globalImages` pattern for automatic support of private image registries ✅
  * (Recommended) Overrides the storage class ❌
  * (Recommended) Overrides the service type to `LoadBalancer` ✅
  * (Optional) Overrides other custom values ✅
  * (Optional) Provides a bind.yaml template ✅
  * (Optional) Provides custom plans ❌

**Service feature check list**:
  * (Recommended) Prevents a new password from being generated on upgrade ❌
  * (Recommended) Support for ability to change password 🤔
  * (Recommended) Support for data backup 🤔
  * (Recommended) Support for zero downtime upgrades 🤔

### [ci-charts](/ci-charts) 

**Description**: For internal use only (contains references to non-publically available image registries).

### [minio](/minio) 

**Description**: A basic Offer comprised of the Bitnami minio helm chart.

**TSMGR feauture check list**:
  * (Recommended) Adheres to the `globalImages` pattern for automatic support of private image registries ✅
  * (Recommended) Overrides the storage class ❌
  * (Recommended) Overrides the service type to `LoadBalancer` ✅
  * (Optional) Overrides other custom values ✅
  * (Optional) Provides a bind.yaml template ❌
  * (Optional) Provides custom plans ✅

**Service feature check list**:
  * (Recommended) Prevents a new password from being generated on upgrade ❌
  * (Recommended) Support for ability to change password 🤔
  * (Recommended) Support for data backup 🤔
  * (Recommended) Support for zero downtime upgrades 🤔

### [mysql-operator](/mysql-operator) 

**Description**: A more advanced Offer comprised of the Presslabs mysql-operator helm chart, and an additional mysql-cluster helm chart (to create mysql clusters using the operator).

**TSMGR feauture check list**:
  * (Recommended) Adheres to the `globalImages` pattern for automatic support of private image registries ❌
  * (Recommended) Overrides the storage class ❌
  * (Recommended) Overrides the service type to `LoadBalancer` ❌ (howerver, no need to override the value here as the default service type is `LoadBalancer`)
  * (Optional) Overrides other custom values ✅
  * (Optional) Provides a bind.yaml template ✅
  * (Optional) Provides custom plans ❌

**Service feature check list**:
  * (Recommended) Prevents a new password from being generated on upgrade ❌
  * (Recommended) Support for ability to change password 🤔
  * (Recommended) Support for data backup 🤔
  * (Recommended) Support for zero downtime upgrades 🤔
  
### [mysql-with-monitoring](/mysql-with-monitoring) 

**Description**: A more advanced Offer comprised of the mysql helm chart, and an additional prometheus helm chart (for monitoring of mysql deployments).

**TSMGR feauture check list**:
  * (Recommended) Adheres to the `globalImages` pattern for automatic support of private image registries ❌
  * (Recommended) Overrides the storage class ❌
  * (Recommended) Overrides the service type to `LoadBalancer` ✅
  * (Optional) Overrides other custom values ✅
  * (Optional) Provides a bind.yaml template ✅
  * (Optional) Provides custom plans ✅

**Service feature check list**:
  * (Recommended) Prevents a new password from being generated on upgrade ❌
  * (Recommended) Support for ability to change password 🤔
  * (Recommended) Support for data backup 🤔
  * (Recommended) Support for zero downtime upgrades 🤔

### [mysql](/mysql) 

**Description**: A basic Offer comprised of the mysql helm chart.

**TSMGR feauture check list**:
  * (Recommended) Adheres to the `globalImages` pattern for automatic support of private image registries ❌
  * (Recommended) Overrides the storage class ❌
  * (Recommended) Overrides the service type to `LoadBalancer` ✅
  * (Optional) Overrides other custom values ✅
  * (Optional) Provides a bind.yaml template ✅
  * (Optional) Provides custom plans ✅

**Service feature check list**:
  * (Recommended) Prevents a new password from being generated on upgrade ❌
  * (Recommended) Support for ability to change password 🤔
  * (Recommended) Support for data backup 🤔
  * (Recommended) Support for zero downtime upgrades 🤔

### [redis](/redis) 

**Description**: A basic Offer comprised of the Bitnami redis helm chart.

**TSMGR feauture check list**:
  * (Recommended) Adheres to the `globalImages` pattern for automatic support of private image registries ✅
  * (Recommended) Overrides the storage class ❌
  * (Recommended) Overrides the service type to `LoadBalancer` ✅
  * (Optional) Overrides other custom values ❌
  * (Optional) Provides a bind.yaml template ❌
  * (Optional) Provides custom plans ❌

**Service feature check list**:
  * (Recommended) Prevents a new password from being generated on upgrade ❌
  * (Recommended) Support for ability to change password 🤔
  * (Recommended) Support for data backup 🤔
  * (Recommended) Support for zero downtime upgrades 🤔

---
sidebar_position: 11
---

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

# RBAC rules for the Release installation

In Kubernetes, an operator is a piece of software that manages a specific application or service on behalf of its users. 
Operators typically use Kubernetes API calls to create, update, and delete resources that are associated with the application or service they manage. 
In order to perform these operations, the operator needs to have the appropriate permissions in Kubernetes.

## Requirements

- Running k8s cluster
- `kubectl` connected to the cluster
- `xl-cli` installed - version 23.3.x
- Release operator - version 23.3.x

## RBAC rules for the `xl kube`

### Installation and Upgrade

During `xl kube install` process is doing apply of the following resource kinds:
- Service
- Secret
- CustomResourceDefinition
- Deployment
- Role
- RoleBinding
- DigitalaiRelease.

Additionally, if there is selected creation of namespace, it is needed create for:
- Namespace.

If there is selected nginx controller installation xl-cli needs to create:
- ClusterRole
- ClusterRoleBinding.

### Clean

To run `xl kube clean` the process needs all the resources that used with `xl kube install`, 
together with resources that are defined for operator with:
- Role: xlr-operator-manager
- Cluster Role: xlr-operator-manager.

Note: Clean is not deleting the namespace, so it does not need permissions on the namespace.

### Upgrade

To run `xl kube upgrade` the process needs all the resources that used with 
- `xl kube install`
- `xl kube clean`
- and all verbs on the Job resource.

## RBAC rules for the Release installation

The operator needs following roles to be able to manage resources for the Release:

- Roles:
  - xlr-operator-leader-election
  - xlr-operator-proxy
  - xlr-operator-manager

- Cluster role:
  - xlr-operator-manager (the name depends on the custom namespace)

All roles have role binding to the default service account that is located in the namespace where the operator will be installed.

### Role: xlr-operator-leader-election

Leader election role is used by operator for internal management of the operator's resources, it is using following resources:
- configmaps
- events
- leases.

This role is used always by the operator.

### Role: xlr-operator-proxy

The role is for operator to determine whether a user or service account has the necessary permissions to perform a particular operation,
and to verify that a user or service account is authenticated and authorized to make API requests.

Operator proxy role is using following resources:
- tokenreviews
- subjectaccessreviews.

This role is used always by the operator.


### Role: xlr-operator-manager

To manage all the resources that are needed for the Release we have this role. Role is giving permission to operator to manage all the resources.

It is used for managing following resources:
- events
- configmaps
- persistentvolumeclaims
- secrets
- serviceaccounts
- services
- deployments
- statefulsets
- daemonsets
- ingresses
- poddisruptionbudgets
- rolebindings
- roles
- digitalaireleases
- digitalaireleases/status
- digitalaireleases/finalizers.

This role is used always by the operator.

### Cluster Role: xlr-operator-manager

This is the only cluster role that is needed by the operator, but it is only used when ingress controller is managed by the operator.
If ingress controller is not managed by the operator (nginx and haproxy ingresses are disabled), this role is not needed.

It is used for managing following resources:
- events
- ingressclasses
- clusterrolebindings
- clusterroles.

For the openshift variant of the operator following additional resources are managed:
- poddisruptionbudgets
- securitycontextconstraints
- and all resources in the route.openshift.io API group.

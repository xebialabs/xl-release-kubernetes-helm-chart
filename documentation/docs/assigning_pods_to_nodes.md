---
sidebar_position: 4
---

# Assigning Pods to Nodes

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

## Prerequisites
- The kubectl command-line tool
- Access to a Kubernetes cluster with installed Release

Tested with:
- xl-release 22.2.0-x
- xl-cli 10.3.9
- Azure cluster

## Intro

All running pods, deployed with xl-release, have no defined:
- pod tolerations
- node labels in the `nodeSelector`
- node (anti-)affinity

If you need to apply on pods custom scheduling to the appropriate node you can use following files to change that in your operator package:
1. `digitalai-release/kubernetes/dairelease_cr.yaml`

    In the file search all places where is `tolerations: []` or `nodeSelector: {}` and add appropriate values there. 

2. `digitalai-release/kubernetes/template/deployment.yaml`

   In the file add to the path `spec.template.spec` appropriate values with `tolerations: []` or `nodeSelector: {}`.

In next sections we will display few cases that could be applied.


## Removing Pods from Specific Node

If you need that specific node should not run any xl-release pods, you can apply taint to that node with effect `NoExecute`, for example:

```shell
❯ kubectl taint nodes node_name key1=value1:NoExecute
```

All pods that do not have that specific toleration will be immediately removed from nodes with that specific taint.


## Assigning XLR Pods to the Specific Nodes

If you need to have just XLR pods, and no other pod, on the specific node you need to do following, for example:

1. Add to nodes specific taints that will remove all other pods without same tolerations: 
```shell
❯ kubectl taint nodes node_name app=dai:NoExecute
```

2. Add label to the same nodes so XLR when deployed use just that specific nodes:
```shell
❯ kubectl label nodes node_name app_label=dai_label
```

3. In the `digitalai-release/kubernetes/dairelease_cr.yaml` update all places with `tolerations`:
```yaml
tolerations:
- key: "app"
  operator: "Equal"
  value: "dai"
  effect: "NoExecute"
```

And update all places with `nodeSelector`:
```yaml
nodeSelector:
  app_label: dai_label
```

4. In the `digitalai-release/kubernetes/template/deployment.yaml` add following lines under `spec.template.spec`:
```yaml
tolerations:
- key: "app"
  operator: "Equal"
  value: "dai"
  effect: "NoExecute"
nodeSelector:
  app_label: dai_label
```

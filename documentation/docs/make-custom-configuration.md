---
sidebar_position: 3
---

# Make custom configuration for the Release

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

## Requirements

- Running Release installation on k8s cluster
- `kubectl` connected to the cluster
- Release operator version above following:
  - 10.2.18
  - 10.3.16
  - 22.0.8
  - 22.1.6
  - 22.2.2

## Steps

1. Download current template configuration file that exists on you Release pod that is running.
It is in the `/opt/xebialabs/xl-release-server/default-conf/xl-release.conf.template` 

    For example:
    ```shell
    kubectl cp digitalai/dai-xlr-digitalai-release-0:/opt/xebialabs/xl-release-server/default-conf/xl-release.conf.template .
    ```

2. Update the CR file or CR on the cluster

    Use that file to update your CR file under `spec.release.configurationManagement.configuration.scriptData` path. Add there the content of the `xl-release.conf.template` file under the `xl-release.conf.template` key.

    Also update the script under the `spec.release.configurationManagement.configuration.script` path. Add there 

    For example:

    ```yaml
    ...
            script: |-
              ...
              cp /opt/xebialabs/xl-release-server/xlr-configuration-management/xl-release.conf.template /opt/xebialabs/xl-release-server/default-conf/xl-release.conf.template && echo "Changing the xl-release.conf.template";
            scriptData:
              ...
              xl-release.conf.template: |-
                xl {
                  ...
                }
    ```

3. If you have oidc enabled, in that case disable it. Because the changes that are from there will conflict with your changes in the `xl-release.conf.template` file.

    Just in CR file put `spec.oidc.enabled: false`.

4. Save and apply changes from the CR file.

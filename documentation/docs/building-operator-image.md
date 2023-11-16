---
sidebar_position: 2
---

# Building the operator image from helm chart

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

:::tip

You have to login to your docker account before executing the script!

`docker login`

:::


## Build and publish with gradle

Requirements:
- Java 11
- operator-sdk
- helm
- make
- docker

Use following task to release the image:

```
./gradlew clean publishToDockerHub --stacktrace
```

With following variables you can influence on version and repository where release will be done:
- `RELEASE_EXPLICIT` - version of them releasing image, use `22.0.0-114.1255` pattern
- `DOCKER_HUB_REPOSITORY` - DockerHub repository name, default is `xebialabsunsupported`

For example:
```
DOCKER_HUB_REPOSITORY=xebialabs && RELEASE_EXPLICIT=22.1.1 && ./gradlew clean publishToDockerHub --stacktrace
```

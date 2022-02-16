---
sidebar_position: 2
---

# Building the operator image from helm chart

## Build and publish with script

Use script `build_operator.sh` to build and publish operator image
```
./build_operator.sh $RELEASE_EXPLICIT $DOCKER_HUB_REPOSITORY $BRANCH
```

Where env variables are:
- `RELEASE_EXPLICIT` - version of them releasing image, use `22.0.0-114.1255` pattern
- `DOCKER_HUB_REPOSITORY` - DockerHub repository name, default is `xebialabsunsupported`
- `BRANCH_NAME` - branch from where release will be done, default is `master` 

## Build and publish with gradle

Use following task to release the image:

```
./gradlew clean publishToDockerHub --stacktrace
```

With following variables you can influence on version and repository where release will be done:
- `RELEASE_EXPLICIT` - version of them releasing image, use `22.0.0-114.1255` pattern
- `DOCKER_HUB_REPOSITORY` - DockerHub repository name, default is `xebialabsunsupported`

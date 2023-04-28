---
sidebar_position: 10
---

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

## Enable HTTP2 for release

When xl-release is started with http2, it starts on https/ssl endpoint. And the the xl-release backend communicates with ingress on the configured http2 backend endpoint.

### Create keystore and certificate using openssl
```
openssl req -x509 -out localhost.crt -keyout localhost.key \ 
  -newkey rsa:2048 -sha256 \
  -subj '/CN=localhost'

openssl pkcs12 -export -in localhost.crt -inkey localhost.key -name localhost -out ssl-keystore.p12 
```
Note down the "keystore password" and "keystore key password" when generating using openssl command. Its required to input them to the chart values.

### Create base64 encoded string of keystore file
```
cat ssl-keystore.p12 | base64 -w 0
```

### [Optional] Create generic secret for keystore (required only when specifying keystore as secret)

```
kubectl create secret generic http2-tls-secret --from-file=ssl-keystore.p12=ssl-keystore.p12 -n digital-ai-release
```

### Fields to update in values.yaml
The following fields in the helm chart values directly or in case of operator installation, to the operator cr yaml under `spec` section are used to enable http2 for release.

```
http2.enabled
ssl.enabled
ssl.keystorePassword
ssl.keystoreKeypassword
ssl.keystore
```

### Sample release helm values yaml snippet for http2 using keystore base64 encoded string  
```
http2:
  enabled: true
ssl:
  enabled: true
  keystorePassword: <ReleaseKeystorePassword>
  keystoreKeypassword: <ReleaseKeystoreKeyPassword>
  keystore: <ReleaseKeystore-converted-to-base64-encoded>
```
### Sample release helm values yaml snippet for http2 using keystore secret
The keystore value can also be provided using a generic kubernetes secret. Like below.
```
ssl:
  keystorePassword: <ReleaseKeystorePassword>
  keystoreKeypassword: <ReleaseKeystoreKeyPassword>
  keystore:
    valueFrom:
      secretKeyRef:
        name: <ReleaseKeystoreSecretName>
        key: ssl-keystore.p12
```
### Installing helm chart
After including the above fields for http2 in the values yaml, run helm install command as follows.
```
helm install -f <values-file> <helm-release-name> . 
```

### Accessing the release UI
The ingress controller charts we support in the release helm chart(nginx and haproxy) do not support http2 backend. We need to setup external ingress controller seperately and configure to handle http2 backends, to expose the release server over public url. 

For accessing release UI without ingress controller setup, suggest to use kubectl port forward release http2 port to localhost and access release UI from localhost:5543.

#### Command to port forward release port to localhost same port
```
kubectl port-forward pod/<release-pod-name> 5543:5543
```
After port forwarding, release UI will be accessible from https://localhost:5543

### Additional info
HTTPS(or SSL enabled transport) is required for http2. XL-Release can be configured to start on http2 endpoint with some configuration changes to `xl-release.conf` and `xl-release-server.conf`. These changes have been baked into the XL-Release docker image. And they can be enabled by some env variables and configuration setting for the docker image. Based on the fields in helm values yaml, the appropriate docker env variables are set and ssl certs are also volume mounted to xl-release image.(for http2).

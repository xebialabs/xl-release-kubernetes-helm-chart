---
sidebar_position: 10
---

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

## Enable HTTP2 for release

When xl-release is started with http2, it starts on https/ssl endpoint. And the the xl-release backend communicates with ingress on the configured http2 backend endpoint.

### Fields to update in values.yaml
The following fields in the helm chart values or alternatively to the operator cr yaml under `spec` section are used to enable http2 for release.

```
http2:
  enabled: true
ssl:
  enabled: true
  keystorePassword: <ReleaseKeystorePassword>
  keystoreKeypassword: <ReleaseKeystoreKeyPassword>
  keystore: <ReleaseKeystore-converted-to-base64-encoded>
```

The keystore value can also be provided using a generic kubernetes secret. Like below.
```
ssl:
  keystore:
    valueFrom:
      secretKeyRef:
        name: <ReleaseKeystoreSecretName>
        key: ssl-keystore.p12
```

### Create keystore and certificate using openssl
```
openssl req -x509 -out localhost.crt -keyout localhost.key \ 
  -newkey rsa:2048 -sha256 \
  -subj '/CN=localhost'

openssl pkcs12 -export -in localhost.crt -inkey localhost.key -name localhost -out ssl-keystore.p12 
```
Note the "keystore password" and "keystore key password" when generating using openssl command. 

### [Optional] Create generic secret for keystore (required only when specifying keystore as secret)

```
kubectl create secret generic http2-tls-secret --from-file=ssl-keystore.p12=ssl-keystore.p12 --from-literal=password=<keystore-pwd> -n digital-ai-release
```

### Additional info
HTTPS(or SSL enabled transport) is required for http2. XL-Release can be configured to start on http2 endpoint with some configuration changes to `xl-release.conf` and `xl-release-server.conf`. These changes have been baked into the XL-Release docker image. And they can be enabled by some env variables and configuration setting for the docker image. Based on the fields in helm values yaml, the appropriate docker env variables are set and ssl certs are also volume mounted to xl-release image.(for http2).

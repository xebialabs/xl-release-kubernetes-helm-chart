
## Installing the opm CLI

Check [Installing the opm CLI](https://docs.openshift.com/container-platform/4.15/cli_reference/opm/cli-opm-install.html)

## Creating an index image

```shell
opm index add \
  --bundles docker.io/xebialabsunsupported/release-operator-bundle:24.1.0-405.823 \
  --tag docker.io/xebialabsunsupported/release-operator-index:latest \
  --generate
```

```shell
docker build -f index.Dockerfile -t docker.io/xebialabsunsupported/release-operator-index:latest .
```

```shell
docker push docker.io/xebialabsunsupported/release-operator-index:latest
```

## Create the CatalogSource

```shell
oc create -f test-operator-catalogsource.yaml 
oc -n openshift-marketplace get catalogsource
oc -n openshift-marketplace get pods
```

```shell
oc -n openshift-marketplace get catalogsource | grep test-operators
oc -n openshift-marketplace get pods | grep test-operators
oc get packagemanifests | grep "Test Operators"
```

## Create OperatorGroup

```shell
oc new-project release-test-operator
```

```shell
oc delete operatorgroup release-test-group -n release-test-operator
```

```shell
oc create -f test-operatorgroup.yaml
```

```shell
oc get operatorgroup
```

## Create a Subscription

```shell
oc delete sub release-test-subscription -n release-test-operator
```

```shell
oc create -f test-subscription.yaml
```

```shell
oc get sub -n release-test-operator
oc get installplan -n release-test-operator
oc get csv -n release-test-operator
```

## Check Result

```shell
oc describe csv -n release-test-operator
```

```shell
oc get pods -n release-test-operator
```

```shell
oc apply -n release-test-operator -f ../config/samples/xlr_minimal.yaml
```

## Upgrade an existing image

```shell
opm index add \
  --bundles docker.io/xebialabsunsupported/release-operator-bundle:24.1.0-405.829 \
  --from-index docker.io/xebialabsunsupported/release-operator-index:latest \
  --tag docker.io/xebialabsunsupported/release-operator-index:latest \
  --generate
```

```shell
docker build -f index.Dockerfile -t docker.io/xebialabsunsupported/release-operator-index:latest .
```

```shell
docker push docker.io/xebialabsunsupported/release-operator-index:latest
```

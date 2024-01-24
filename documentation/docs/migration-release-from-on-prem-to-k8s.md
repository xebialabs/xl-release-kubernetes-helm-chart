---
sidebar_position: 22
---

#  Migrate an existing Digital.ai Release installation to Kubernetes (v23.3 and v24.1)

:::caution
This is internal documentation.
The document can be used only if it was recommended by the Support Team.
:::

:::caution
This document is for a Release version from 23.3 and up.
:::

Following steps should cover the general process of moving your Digital.ai software onto a Kubernetes platform. 
Note that details can vary depending on your specific situation, needs, and pre-existing infrastructure.

:::warning:
This guide is technical in nature. Before starting the migration process, make sure you have a proficient level of understanding about your 
existing infrastructure, Kubernetes, and the Digital.ai Release products.
If you have more specific questions about any of these steps, feel free to ask!
:::

## 1. Preparation

Make sure all necessary prerequisites are in place. These include things like:
- setting up your Kubernetes cluster, 
- installing and configuring required Kubernetes CLI tools, 
- preparing necessary information for PostgreSQL and RabbitMQ servers if existing ones are to be used.

:::TIP
Read through the xl kube workshop to gain a comprehensive understanding of how to install or upgrade Digital.ai Release or Release or Remote Runner on a kubernetes cluster.
See:
- [xl-kube-workshop](https://github.com/xebialabs/xl-kube-workshop)
- [Helm chart documentation](https://github.com/xebialabs/xl-release-kubernetes-helm-chart/tree/23.3.x-maintenance) - the Release operator is managing Release helm chart on K8S cluster
:::

This manual is for 23.3 and 24.1 versions (or above). 
The target version of Release needs to be aligned with tools used (xl), and supported java version. 
Also, the version of on-prem Release before migration needs to be the same to the target version of the Release that will be installed on K8S cluster.

### 1.1. Requirements for Client Machine

#### Mandatory
- Installed [xl](https://dist.xebialabs.com/public/xl-cli/) - same version of the Release you plan to install on K8S cluster
  - [Install the XL CLI](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/how-to/install-the-xl-cli.html)
- Installed [yq](https://github.com/mikefarah/yq) 4.18.1 or higher.
- Installed [kubectl](https://kubernetes.io/docs/tasks/tools/) version +/-1 from the target K8S cluster version.
- Network connection to the selected K8S cluster with kubectl context setup

#### Optional
- Installed Java 11/17 - keytool (only if you plan to use the generation of the keystore from the xl-cli kube) - the version depends on Release's Java version
- Installed [helm](https://helm.sh/docs/intro/install/) - if you would like to get additional info during installation - the latest version
- Installed docker image registry compatible cli to push/pull images - if you need to pull/push images from `docker.io` to the private K8S image registry
  - [docker-cli](https://docs.docker.com/get-docker/)
  - [podman-cli](https://podman.io/docs/installation) - as alternative to docker cli to push/pull images

### 1.2. Select the Desired Cloud Platform for Migration

The migration supports multiple platforms including (here are also links with some details that are important for the specific provider):
- Plain Multi-node Kubernetes Cluster On-premise, 
- OpenShift (on [AWS](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-install-on-aws-openshift.html), Azure and on other providers), 
- [Amazon EKS](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-install-on-eks.html), 
- [Google GKE](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-install-on-gke.html), and 
- [Azure AKS](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-install-on-aks.html).

### 1.3. Provide Docker Image Tags

While the default (latest) Docker image tags will be used, it's possible to verify all available tags using the corresponding Docker Hub links. 

Here is the list of images for 23.3 version: [Prerequisite Images](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-setup-custom-image-registry.html#step-1-get-prerequisite-images).
Check if all images are available on your K8s cluster.

If you plan to use private image registry, check how to setup it during installation: 
[Install or Upgrade Release on an Air-gaped Environment](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-install-upgrade-airgapped-release.html)

### 1.4. Release Server Replicas

Estimate the number of Release replicas required for your installation and the resources that are needed on cluster. 
With that estimate check have you enough the number of nodes in the K8S cluster. 

### 1.5. Configure your Kubernetes Cluster

#### 1.5.1. Resource Sizing

Plan the sizing of the Release pod resources. Check resources that are needed for normal installation, the sizing of the Release pod should be the same:
   - [Release Server Hardware Requirements](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/requirements-for-installing-xl-release.html#release-server-hardware-requirements)

#### 1.5.2. Namespace

Define a namespace for the installation. By default, it's `digitalai`, but a custom namespace can be used.

Choose the Ingress Controller to use. Nginx and HAProxy are supported, or you can use existing ingress class from K8S cluster, or no ingress.
- You will need a registered domain name (FQDN) to access the UI.
- Possibly enable SSL/TLS protocols in your cluster. If so, you will need to create a TLS certificate and key as a secret in your cluster.

#### 1.5.3. License

Have a valid license for the services to be installed. License files can be in plain text format or base64 encoded format. 
See [Licensing the Release Product](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/xl-release-licensing.html)

#### 1.5.4. Repository Keystore File
   
Copy your repository keystore file `repository-keystore.jceks` and keystore password in clear-text from the Release conf directory to the client machine. 
The keystore file is in the `conf` directory of your existing Release instance: `conf/repository-keystore.jceks`, it contains an encryption key for DB repository.
You need to reuse that file during `xl kube install` installation in the step 6.1.

#### 1.5.5. Relational Database

Choose whether you will be using database:
- an existing relational database server supported by Release's target version, or 
- create new one external relational database supported by Release, or 
- create a new one PostgreSQL database during the installation that will run inside the Kubernetes cluster. 
If the former, there is some required information you will need to gather. Check the list of supported databases and version, and storage sizing:
- [Supported Databases](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/requirements-for-installing-xl-release.html#supported-databases)
- [Database Server Hardware Configuration](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/requirements-for-installing-xl-release.html#sql-database-server)
- [Using an Existing PostgreSQL Database](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-external-db.html)

:::note
If you plan to use an external database, pay attention to the latency between your cluster and DB instance, it will play a big part in the final Release performance.
:::

#### 1.5.6. Message Queue

The same decision and process also applies to RabbitMQ server (as for Relational Database).

- [Using an Existing RabbitMQ Message Queue](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-external-mq.html)

#### 1.5.7. Authentication

Optionally, configure OIDC for authentication. It can be:
- an existing server such as [Keycloak](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/release-oidc-with-keycloak.html), [Okta, Azure Active Directory](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/xl-release-oidc-authentication.html);
- integrated with [Digital.ai's Identity Service platform](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/how-to/release-integrating-with-identity-service.html); 
- integrated with [LDAP](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/how-to/configure-ldap-security-for-xl-release.html) 
- or use no OIDC authentication in favor of Digital.ai's own DB-based local user authentication.

Check the selection details in the documentation [SSO Authentication Options](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/release-plan-your-sso-authentication.html)

Configuration of the OIDC part is done during xl kube installation, check documentation: [Select the Type of OIDC Configuration](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-install-oidc-configuration.html)

:::note
If you plan to use an LDAP, it requires update of the file `conf/xl-release-security.xml`, there is an example how to customize that file in 
[dai-release_cr-example.yaml](./yamls/dai-release_cr-example.yaml). Check the section in the file 
`spec.extraConfiguration.default-conf_xl-release-security_xml` and `spec.extraConfiguration.default-conf_xl-release-security_xml`, and in this document section 5.3. how to do changes. 
:::

#### 1.5.8. Storage

Estimate PVC size for Release, PostgreSQL, and RabbitMQ:
- [Reference Setup](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/requirements-for-installing-xl-release.html#reference-setup)
- [Database Server Hardware Configuration](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/requirements-for-installing-xl-release.html#sql-database-server)
   
Select the storage class, for the Release is enough to use any ReadWriteMany access mode supported storage class.
Default storage classes are created in Kubernetes clusters that run Kubernetes version 1.22 or later, but you can create your own to suit your needs.
Check details on the tested storage classes: [Storage class support (not public, ask for the copy)](https://digitalai.atlassian.net/wiki/spaces/Labs/pages/77226606593/Storage+class+support)

## 2. Upgrade Release on the Target Version

It is expected that migration of the Release to the K8S cluster will be done with the same version of the Release (during the migration, there will be no upgrade of the version).

For more details, check [Upgrade Release 9.7.x and later to current](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/how-to/upgrade-9.7.x-to-current.html)

## 3. Switch Plugin Source to Database

The K8S version of the Release is working with the database plugin source. 
In case you are already using the database - `-plugin-source database`, skip this section.

In the other way for more details, check:
- [Plugin synchronization](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/concept/plugins-synchronization.html)

With this option enabled before migration, all plugins will be stored in the database. 

## 4. Backup Current Installation

### 4.1. Shut down the existing Release server.

### 4.2. Backup database

Back up your database installations, here is an example with a separated main and report PostgreSQL database:
```shell
mkdir -p /tmp/postgresql/backup
pg_dump -U xlr xlr-db | gzip > /tmp/postgresql/backup/pg_dump-xlr-db.sql.gzip
# execute this if you have separate xlr-report-db 
pg_dump -U xlr-report xlr-report-db | gzip > /tmp/postgresql/backup/pg_dump-xlr-report-db.sql.gzip
```

Use the database username and password according to your PostgreSQL database setup.

:::note
Make sure that the directory where you are storing backup has enough free space.
:::

### 4.3. Backup all customized Release directories

For example, possible changes could be in directories:
- conf
- ext
- hotfix

See details for the backup: [Back up Release](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/how-to/back-up-xl-release.html)

## 5. Installation Release Digital.ai on K8S Cluster

### 5.1. Generate K8S Configuration

Use the 
```shell
xl kube install --dry-run
```
command from the XL CLI to generate initial installation files for Digital.ai Release.

During execution, you will need prepared items from section 1.5.
Use the collected information from the previous steps to answer the questions and do initial generation of the resource files for the target namespace.
About setup check for details in the documentation:
- [Installation Options Reference for Digital.ai Release](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-install-wizard-release.html)
- [XL Kube Command Reference](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-kube.html)

The last few lines of the command run will be similar following log:

```log
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20240122-120535/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_install-20240122-120535.yaml
Starting install processing.
Created keystore digitalai/dai-release/digitalai/20240122-120535/kubernetes/repository-keystore.jceks
Skip creating namespace digitalai, already exists
Generated files successfully for PlainK8s installation.
Applying resources to the cluster!
Applied resource service/xlr-operator-controller-manager-metrics-service from the file digitalai/dai-release/digitalai20240122-120535/kubernetes/template/controller-manager-metrics-service.yaml
Applied resource customresourcedefinition/digitalaireleases.xlr.digital.ai from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/custom-resource-definition.yaml
Applied resource deployment/xlr-operator-controller-manager from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/deployment.yaml
Applied resource role/xlr-operator-leader-election from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/leader-election-role.yaml
Applied resource rolebinding/xlr-operator-leader-election from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/leader-election-rolebinding.yaml
Applied resource role/xlr-operator-manager from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/manager-role.yaml
Applied resource rolebinding/xlr-operator-manager from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/manager-rolebinding.yaml
Applied resource role/xlr-operator-proxy from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/proxy-role.yaml
Applied resource rolebinding/xlr-operator-proxy from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/template/proxy-rolebinding.yaml
Applied resource digitalairelease/dai-xlr from the file digitalai/dai-release/digitalai/20240122-120535/kubernetes/dai-release_cr.yaml
Install finished successfully!
```

:::note
In the next steps we will do updates to the CR yaml file, to reflect all the custom changes that are already available on the on-prem Release installation. 
The changes will go mainly in the custom-resource (CR) yaml file that is in our case: `digitalai/dai-release/digitalai/20240122-120535/kubernetes/dai-release_cr.yaml`, 
we will refer it from now with `dai-release_cr.yaml` name.

At the end of migration, the generated files from this step will be applied on the K8S cluster, so preserve files, maintain yaml formatting, and be careful what you change in the files. 
:::

### 5.2. Resource Configuration

Put a changes in the `dai-release_cr.yaml`, in each section, according to your previous estimations for the target product installation. 
Check in the example file [dai-release_cr.yaml](yamls/dai-release_cr-example.yaml) following sections:
- `spec.resources` 
- `spec.postgresql.resources` 
- `spec.rabbitmq.resources` 

The numbers in the example are not maybe what is required by your requirements.

### 5.3. Configuration file changes (optional)

If you don't have any customization in the configuration files (in the Release's conf directory), you can skip this section.

First check documentation how we manage the configuration files in the operator environment: 
[Customize Your Site—Custom Configuration of Release](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-customize.html)

In the documentation, it is described how to do changes if you have already had running Release on K8S cluster. 
During the migration we can do changes directly in the `dai-release_cr.yaml` file.

The changes from your on-prem configuration files need to go in the templates that you can get from the template directories. 
To get templates, you can run pods without running the Release, configuration:
```shell
kubectl run release-01 -n digitalai --image=xebialabs/xl-release:23.3.2 --command -- /bin/bash -c "sleep infinity"
```
After that, you can get the templates from the Release pod, similar to the documentation.

For any file that you would like to override in the configuration override its template:
1. Download the template
2. Change the file with custom changes
3. Put the file in the CR `dai-release_cr.yaml`, under 
  - `spec.extraConfiguration` section.

Check the example file [dai-release_cr.yaml](yamls/dai-release_cr-example.yaml) under 
- `spec.extraConfiguration`

section, there are examples of how to customize:
- `default-conf/xl-release-security.xml`
- `default-conf/deployit-defaults.properties`

In the same way, you can change any file in the configuration directory.

### 5.4. Other customizations (optional)

#### 5.4.1. Truststore

If you don't use truststore in your Release setup, you can skip this section.

Check the documentation how to set up it: [Set up Truststore for Release](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-setup-truststore.html).
Instead of applying the changes on the cluster use update the `dai-release_cr.yaml` file directly. 

#### 5.4.2. Set up JVM Arguments

If you need to set up some additional JVM arguments, check: [Set up JVM Arguments for Application Containers](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-setup-jvm-arguments.html).
Instead of applying the changes on the cluster use update the `dai-release_cr.yaml` file directly.

#### 5.4.3. Set up file logging

In the default setup the Release logging is not persisted to the filesystem, you can customize the configuration according to the examples:
- [Logging configuration scan & configuration values (not public, ask for the copy)](https://digitalai.atlassian.net/wiki/spaces/Labs/pages/77215137848/Logging+configuration+scan+configuration+values)
- [File logging with K8s operator (not public, ask for the copy)](https://digitalai.atlassian.net/wiki/spaces/Labs/pages/77215137976/File+logging+with+K8s+operator)

### 5.5. Test the Setup with Temporary Installation (optional)

If you would like, you can test the configuration before using existing or migrated data. 
The reason for this is to minimize downtime and to observe possible problems before using existing DB. 
In this section, we will start prepared configuration without any data so we can test that all is ok with our configuration changes.

#### 5.5.1 Change database configuration to temporary database

In case you are using an existing database, and you have already referenced it in the configuration; we need to change it to some other DB.
Create some temporary database, or delete the content of the database after this test:
- If you would like use the external **temporary** database: change the configuration to reference it from the section in the `dai-release_cr.yaml`: `spec.external.db`.
- If you would like to use the same external **empty** database, that same in the final installation: you will need to delete the content of the database after this test installation.
- If you have a configuration for PostgreSQL database that is part of the operator installation: you don't need to do anything.

#### 5.5.2. Apply temporary installation to cluster

```shell
xl kube install --files 20240122-120535
```

That command should apply all the files that are created by dry-run.

#### 5.5.3. Check the Test Installation

See section 6. to validate test installation. 

#### 5.5.4. Restore the Database Configuration

If you were using for tests external **temporary** database, restore the configuration in the `dai-release_cr.yaml` file under section `spec.external.db`.

If you were using for tests an external **empty** database, that is the same as in the final installation:
you will need to delete the content of the database after this test installation to restore migration data.

### 5.6. Restore Data to Target DB (optional)

If you are using an existing database from the previous installation, no need to do anything here, you are already set database configuration by setting external DB params during dry-run.

If the existing DB is not the same that you previously used in on-prem installation, be sure that you migrated the data to the new database, that is not part of this guide. 

In case you are using the PostgreSQL DB that is part of the Release operator installation, check this steps:

#### 5.6.1 Change replica count for Release pods

We need first to start the PostgreSQL that is part of the operator installation, but without Release running.
Change the replica count for Release, put to `0` values under:
- `spec.replicaCount`

#### 5.6.2. Apply temporary installation to cluster

```shell
xl kube install --files 20240122-120535
```

That command should apply all the files that are created by dry-run and start PostgreSQL pod 
(and other pods Release operator, RabbitMQ, ingress if enabled). 

#### 5.6.3. Restore the Data

In this case, it is essential that Release is not connected to the database. 
Because restore will fail with errors about duplicate database entities.

For this step, you need to have already prepared dump that is compatible with PostgreSQL restore (check how to do backup in the step: 5.3.).
Be sure that the target directory on the pod exists (in the example we are using `/bitnami/postgresql/backup` that is mounted to have enough free space).

Execute the code to upload DB dump files to the PostgreSQL pod:
```shell
kubectl cp -c postgresql pg_dump-xlr-db.sql.gzip digitalai/dai-xlr-postgresql-0:/bitnami/postgresql/backup/pg_dump-xlr-db.sql.gzip
# execute this if you have separate xlr-report-db
kubectl cp -c postgresql pg_dump-xlr-report-db.sql.gzip digitalai/dai-xlr-postgresql-0:/bitnami/postgresql/backup/pg_dump-xlr-report-db.sql.gzip
```

Connect to PostgreSQL pod console and restore the data to local DB:
```shell
gunzip -c /bitnami/postgresql/backup/pg_dump-xlr-db.sql.gzip | psql -U xlr xlr-db
# execute this if you have separate xlr-report-db
gunzip -c /bitnami/postgresql/backup/pg_dump-xlr-report-db.sql.gzip | psql -U xlr-report xlr-report-db
```

:::note
Make sure that the directory on Pod where you are storing backup has enough free space.
:::

### 5.7. Apply the Setup on K8S Cluster

### 5.7.1 Review the `dai-release_cr.yaml`

Review the content of the `dai-release_cr.yaml`. 

Rollback temporary changes in case you have them:
- replica count from the 5.6.1 step;
- database configuration from the 5.5.1 step.

### 5.7.2 Apply final installation to cluster

If you have already resources created on the cluster, this step will update them.

```shell
xl kube install --files 20240122-120535
```

That command should apply all the files and start all Release pods on cluster.

## 6. Check the Installation

###  6.1 Check the resources

The following command will check and wait to Release resources (if they are not yet available on the cluster):

```shell
xl kube check
```

Command will fail if there are missing not-ready resources.

###  6.2 Check the connection

Check if Release is working correctly by using port-forwarding to the service (example for digitalai namespace):
```shell
kubectl port-forward -n digitalai svc/dai-xlr-digitalai-release 5516:5516
```
And open in a browser URL: http://localhost:5516/

Or check if ingress (or route) setup is working by opening the URL in a browser that you setup for ingress (or route).

## 7. Rollback

In case you are not satisfied with migration, you can go back to the on-prem setup: 

### 7.1. Clean Current Installation from K8S Cluster

```shell
xl kube clean
```

The command will clean all the resources from the cluster.

### 7.2. Start back on-prem Release

Use the already available installation on-prem Release to start it. 

## 8. Final Notes

To minimize downtime plan your migration, execute the following steps on the end:
- all the steps from section 4.
- and after that steps 5.6., 5.7.

Additional plugin management after migration can be done by using `xl plugin` commands, check 
[Manage Plugins in Kubernetes Environment](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-plugin-management.html)

If you need some additional customization of the Release installation, check [Update Parameters in the CR File or Deployment](https://docs.digital.ai/bundle/devops-release-version-v.23.3/page/release/operator/xl-op-release-apply-changes-from-custom-resource.html)

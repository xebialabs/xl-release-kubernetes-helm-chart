---
sidebar_position: 5
---

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

#  Manual integration with the Identity Service

## Prerequisites
- There is an account in the platform to connect to the Release instance (https://demoaccount.staging.digital.ai)
- There is an admin user (role account-admin) in the account that can be used to configure the Release client (contact Kraken team)

## 1. Adding the Release client
1. Log into the Identity Service account you want to connect to Release using an admin user for that account
2. Go to Admin > Clients > Add OIDC Client
3. Give the client a name (e.g. release)
4. Scroll down to “Valid Redirect URIs” and add
```text
<release url>/oidc-login
```
5. Save the client

## 2. Configuring Release
In CR file disable Keycloak and update OIDC properties:
```yaml
  oidc:
    enabled: true
    clientId: "<client_id>"
    clientSecret: "<client secret>"
    external: true
    issuer: "https://identity.staging.digital.ai/auth/realms/demoaccount"
    postLogoutRedirectUri: "<release url>/oidc-login"
    redirectUri: "<release url>/oidc-login"
    userNameClaim: preferred_username
    rolesClaim: "realm_access.roles"
    scopes: ["openid"]
```
To find the client id and secret, edit the Release client created above, scroll down to the Credentials section, and copy the values from there.

issuer can be found in the Identity Service Client section, in the OIDC config that can be downloaded from there.

To check rolesClaim value, decode the ID token.
[Here](https://docs.xebialabs.com/v.22.2/deploy/concept/deploy-oidc-with-keycloak/#test-public-rest-apis) you can find how to fetch token.
Use [jwt](https://jwt.io/) to decode ID token. Get the roles path from decoded value - this is rolesClaim.

## 3. Deploy Release
Deploy Release and navigate to the Release site in the browser. Log in to the XLR with user from the Identity Service.
   

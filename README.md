# Authentication Fallback Demo

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

This repository provides resources to run a demo environment demonstrating authentication fallback using the Curity Identity Server. 

The repository contains a build script that will:

- Build the service-status-checker authentication action
- Build a custom Curity Identity Server Docker image containing the service-status-checker

The repository also provides a deploy script that:
- Checks that a Curity Identity Server license is available
- Starts a docker compose project with 
    - The Curity Identity Server custom container
    - A Postgresql database container
    - An OpenLDAP container

## Prerequisites

The following minimal requirements are needed to run the demo environment:

- Docker Desktop
- A valid Curity Identity Server license (that allows use of the [plugin SDK](https://curity.io/docs/identity-server/developer-guide/plugins/))

## Building and running the demo

### Environment variables
Start by setting the appropriate environment variables by running:
```bash
cp deployments/.env.example deployments/.env
```

Then edit `deployments/.env` and set:
- OIDC_CONFIGURATION_URL
- OIDC_CLIENT_ID
- OIDC_CLIENT_SECRET
- IDSVR_BASE_URL (can be set but not needed for the demo to run)

These parameters will be used by the configuration to set up the OpenID Connect (OIDC) Authenticator. This is the authenticator that we later simulate being unavailable.

### OpenLDAP configuration
OpenLDAP is used for the fallback authenticator. E.g. when the configured OIDC Authenticator is unavailable the system will automatically fallback to use an HTML Form Authenticator that uses LDAP as its Credential Manager. An OpenLDAP configuration is provided in `deployments/ldif/bootstrap.ldif`. Tweak this to your needs before building and deploying the demo environment.

In a production environment this source might be a replica of the source used by the OIDC Authenticator. As an example, the OIDC Authenticator could be federating to Entra and the fallback option could be a local Active Directory instance that is synchronized with Entra.

### Build and deploy the demo
First make sure a valid license for the Curity Identity Server is placed in the root of this project and that it is named `license.json`.

Build the demo by simply running `./build.sh`.

Next deploy the demo by running `./deploy.sh`. This starts the needed docker containers. 

Note that it is possible to uncomment the `phpldapadmin` block in `deployments/docker-compose.yml` if a UI is needed to work with the OpenLDAP configuration.
Run a code flow using client-one/Password1

### Test fallback

Run an OAuth Code Flow, preferably using [OAuth Tools](https://curity.io/resources/learn/test-using-oauth-tools/). The client_id is `client-one` and the client_secret is `Password1` in the provided configuration. Starting the flow will look like something like this:

```sh
https://localhost:8443/oauth/v2/oauth-authorize?
&client_id=client-one
&response_type=code
&redirect_uri=https://oauth.tools/callback/code
&prompt=login
```

Provided that the configured OIDC Authenticator is actually working that should be triggered and authentication should be straight forward. The service-status-checker will determine that the service is up and set the attribute `serviceIsUp=true`. This is visible in the debug authentication action that is invoked at the end of the authentication pipeline.

There are several ways to trigger the fallback but one easy way of doing so is to simply change the URL that the service-status-checker authentication action is monitoring. Log in to the Curity Identity Server Admin UI and navigate to Profiles &#8594; Authentication Service &#8594; Actions &#8594; service-status-checker. Change the `Service URL` to something that is not valid (add some characters at the end for example).

![Service Status Checker Config](/docs/service-status-checker-config.jpg)

Run an OAuth Code Flow again. The service-status-checker authentication action will fail the check of the URL and set the attribute `serviceIsUp=false`. This in its turn will invoke the HTML Form Authenticator instead of the OIDC Authenticator. Authenticate using an available LDAP account. For example `alice / Password1`. The available accounts are defined in [bootstrap.ldif](./deployments/ldif/bootstrap.ldif).

##  Teardown
To tear down the environment run `./teardown.sh`. This will remove all the resources used in this demo.

## Further Reading

[The Authentication Fallback article](https://curity.io/resources/learn/authentication-fallback/) describes the demo in more detail.

If you want more information about the Curity Identity Server, Identity and Access Management, OAuth or OpenID Connect, then have a look at the [resources](https://curity.io/resources/) section of the [Curity](https://curity.io) website.

If you have any questions or comments don't hesitate to open an issue in this repository or contact us.

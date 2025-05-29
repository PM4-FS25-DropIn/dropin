# Supabase Deployment and Configuration
The goal of this document is to describe how Supabase is deployed and configured.

As decided at the meeting on 23 Mar 2025, we self-host our Supabase instance. Due to Supabase’s size, this is not impossible, though a bit complex. Our Supabase instance is hosted and deployed through a Docker image on our ZHAW-provided server.

Supabase itself does not provide a “complete” image for all their services, but an exemplary Docker Compose, which we are using. The compose file is included in our own compose file are located under `server/docker`. We use Supabase as provided by Supabase. However, it is unlikely that we will use all its features. To shield our services from the outside, we use the Supabase-provided reverse proxy “KONG” as given by Supabase.

## Building the Container
To build the container, navigate to the `server` directory. From there, run the `build.docker.*` script appropriate for your platform/preference.
Once the build is complete, the image is ready to use. Just don't forget to configure the environment variables below.

Database migrations are automatically applied during the startup of the container. 

## Environment Variables
### DropIn Image
The environment variables for our image are defined in `server/docker/.env`. A ready-to-run `.env` file is not included in the repository, but a template is available in the same directory.


### Supabase Image
The Supabase configuration is stored on the server in the `~/server/supabase/.env`. Again, a ready-to-run `.env` for Supabase is not included in the repository, but a template is available in the same directory. Please make sure not to check in the secrets into Git.

The following table provides an overview of important configuration keys:

| Config Value          | Value                                                                 |
|-----------------------|-----------------------------------------------------------------------|
| POSTGRES_PASSWORD     | The password of the Postgres database used by Supabase                |
| JWT_SECRET            | The secret used for the JWT Secret (keep this a secret)               |
| ANON_KEY              | (Use the Supabase page to configure this)                             |
| SERVICE_ROLE_KEY      | (Use the Supabase page to configure this)                             |
| DASHBOARD_USERNAME    | Username of the Supabase Dashboard                                    |
| DASHBOARD_PASSWORD    | Password of the Supabase Dashboard                                    |
| VAULT_ENC_KEY         | The key used to encrypt the Supabase Vault                            |
| SUPABASE_PUBLIC_URL   | The URL the Supabase Dashboard is available through                   |
| KONG_HTTP_PORT        | The port used for the Supabase API Gateway                            |
| SMTP_ADMIN_EMAIL      | The email address used                                                |
| SMTP_HOST             | The SMTP host                                                         |
| SMTP_PORT             | The SMTP port used                                                    |
| SMTP_USER             | The name used to authenticate against the SMTP Server                 |
| SMTP_PASS             | The password used to authenticate against the server                  |
| SMTP_SENDER_NAME      | The name displayed as the sender                                      |
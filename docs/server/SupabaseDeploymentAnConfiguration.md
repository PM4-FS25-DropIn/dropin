# Supabase Deployment and Configuration

The goal of this document is to describe how Supabase is deployed and configured.

As decided at the meeting on 23 Mar 2025, we self-host our Supabase instance. Due to Supabase’s size, this is not impossible, though a bit complex. Our Supabase instance is hosted and deployed through a Docker image on our ZHAW-provided server.

Supabase itself does not provide a “complete” image for all their services, but an exemplary Docker Compose, which we are using. The compose file is included in our own compose file located under `GIT_ROOT/docker`. We use Supabase as provided by Supabase. However, it is unlikely that we will use all its features. To shield our services from the outside, we use the Supabase-provided reverse proxy “KONG” as given by Supabase.

## Configuration Variables

The Supabase configuration is stored on the server in the `~/server/supabase/.env`. Please make sure not to check in the secrets into Git.

The following table provides an overview of important configuration keys:

| Config Value          | Value                                                                 |
|-----------------------|----------------------------------------------------------------------|
| POSTGRES_PASSWORD     | The password of the Postgres database used by Supabase                |
| JWT_SECRET            | The secret used for the JWT Secret (keep this a secret)               |
| ANON_KEY              | (Use the Supabase page to configure this)                            |
| SERVICE_ROLE_KEY      | (Use the Supabase page to configure this)                            |
| DASHBOARD_USERNAME    | Username of the Supabase Dashboard                                    |
| DASHBOARD_PASSWORD    | Password of the Supabase Dashboard                                    |
| VAULT_ENC_KEY         | The key used to encrypt the Supabase Vault                            |
| SUPABASE_PUBLIC_URL   | The URL the Supabase Dashboard is available through                   |
| KONG_HTTP_PORT        | The port used for the Supabase API Gateway                            |
| SMTP_ADMIN_EMAIL      | The email address used (do not change) (Currently: dropin@test-p7kx4xw10neg9yjr.mlsender.net) |
| SMTP_HOST             | The SMTP host (Currently: dropin@test-p7kx4xw10neg9yjr.mlsender.net) |
| SMTP_PORT             | The SMTP port used (Currently: 587)                                   |
| SMTP_USER             | The name used to authenticate against the SMTP Server (Currently: MS_Q28G56@test-p7kx4xw10neg9yjr.mlsender.net) |
| SMTP_PASS             | The password used to authenticate against the server                  |
| SMTP_SENDER_NAME      | The name displayed as the sender (Currently: DropIn)                  |

## Public Endpoints

Currently, the following targets are publicly available:

| URL                          | Description                     |
|------------------------------|---------------------------------|
| http://160.85.252.162:8080   | Supabase Kong endpoint          |
| http://160.85.252.162:80     | DropIn API Endpoint             |

## Email

As of writing this, no SMTP provider has been configured. If we need to send emails in the future, e.g., for email verification, keep in mind that we have a free testmail.app subscription through the GitHub Education Pack!
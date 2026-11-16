[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/activepieces-6?utm_medium=integration&utm_source=button&utm_campaign=activepieces)

# Activepieces on Railway

A Railway template for [Activepieces](https://www.activepieces.com), the open-source automation tool (an alternative to Zapier and Make) with 600+ integrations, AI agents and MCP servers.

## What it deploys

| Service | Source | Notes |
|---|---|---|
| **Activepieces** | this repo (`Dockerfile`) | `activepieces/activepieces:0.93.0`, pinned by digest. API, web app and flow worker in one container. Public HTTPS domain, health check `/api/v1/health`. |
| **Postgres** | Railway Postgres | Flows, runs, connections and files. Railway's image includes pgvector, which Activepieces' knowledge base uses. |
| **Redis** | Railway Redis | Job queue (BullMQ). |

The first account you sign up with becomes the platform admin. There is no default user or password.

## Variables

| Variable | Value in the template | Purpose |
|---|---|---|
| `AP_FRONTEND_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL used for redirects and webhook URLs. Change it if you add a custom domain. |
| `AP_ENCRYPTION_KEY` | generated, 32 hex characters | Encrypts saved connections. Don't change it after first boot. |
| `AP_JWT_SECRET` | generated, 64 hex characters | Signs login and worker tokens. |
| `AP_POSTGRES_URL` | `${{Postgres.DATABASE_URL}}` | Database connection. |
| `AP_REDIS_URL` | `${{Redis.REDIS_URL}}` | Queue connection. |
| `PORT` | `8080` | Port the app listens on. |

`railway-start.sh` fills in the rest with upstream's defaults (`AP_ENVIRONMENT=prod`, `AP_EXECUTION_MODE=UNSANDBOXED`, and so on). Set a service variable of the same name to override any of them. Optional settings such as SMTP, S3 file storage and Google sign-in are listed in the [environment variable reference](https://www.activepieces.com/docs/install/reference/environment-variables).

### Sandboxing

`AP_EXECUTION_MODE=UNSANDBOXED` (upstream's default) suits a single team: code steps can use npm packages. If people you don't trust will write code steps, set `AP_EXECUTION_MODE=SANDBOX_CODE_ONLY` (V8 isolates, no npm packages). Both run on Railway without privileged containers. `SANDBOX_PROCESS` and `SANDBOX_CODE_AND_PROCESS` need a privileged container and don't work on Railway.

## Updates

The Activepieces version is pinned in the `Dockerfile`. When this repo's `main` branch moves to a new version, Railway shows an "update available" notice on your project, and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) and Activepieces' [breaking changes](https://www.activepieces.com/docs/install/reference/breaking-changes) first, and back up Postgres before a major upgrade. Database migrations run on start.

## Run it locally

```sh
docker build -t activepieces-railway .
docker run -p 8080:8080 -e PORT=8080 \
  -e AP_FRONTEND_URL=http://localhost:8080 \
  -e AP_ENCRYPTION_KEY=$(openssl rand -hex 16) -e AP_JWT_SECRET=$(openssl rand -hex 32) \
  -e AP_POSTGRES_URL=postgres://... -e AP_REDIS_URL=redis://... \
  activepieces-railway
```

## License

The wrapper files in this repo are MIT. Activepieces itself is under its own [license](https://github.com/activepieces/activepieces/blob/main/LICENSE) (MIT for the community edition).

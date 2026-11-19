# ShopNest CI/CD Pipeline & Infrastructure

ShopNest is a three-tier e-commerce application composed of a frontend client, a Node.js backend API, a PostgreSQL database (`infra/db/init.sql`), and an Nginx reverse proxy (`infra/nginx/shopnest.conf`), automated with GitHub Actions for target Linux/EC2 environments.

## CI vs. Continuous Delivery vs. Continuous Deployment

* **Continuous Integration (CI):** Code changes are integrated frequently and validated automatically on pushes and pull requests via linting, unit tests, builds, and artifact packaging.
* **Continuous Delivery:** Every change that passes CI is built, packaged into release artifacts, and kept in a ready-to-release state (including staging/verification deployment), while keeping explicit control over production promotion.
* **Continuous Deployment:** Every change that passes automated checks and staging verification is promoted automatically all the way to production without manual intervention.

### Choice for ShopNest
For an e-commerce platform like ShopNest—where storefront availability, product catalogs, carts, orders, and customer records must stay reliable—**Continuous Delivery with automated staging promotion and controlled production environments (`staging` → `production`)** is the strongest fit. Automated CI and staging runs catch regressions early, while protected `main` branch rules, GitHub environment scoping (`staging` and `production`), `/health` verification, and rollback scripts protect production stability.

## Architecture & Pipeline Flow

1. **Branch Protection & Pull Requests:** `main` is protected so changes arrive via Pull Requests and must pass required status checks (`Backend` and `Frontend` across Node.js `20.x` and `22.x`).
2. **CI Pipeline (`.github/workflows/ci.yml`):** Installs dependencies (`npm ci`), runs linting, tests, and builds across the matrix, and uploads build artifacts (`shopnest-backend-<sha>` and `shopnest-frontend-dist-<sha>`).
3. **CD Pipeline (`.github/workflows/cd.yml`):** Triggers after a successful `CI` workflow run on `main` (or manually via `workflow_dispatch`), downloads the CI artifacts, and runs sequential `Deploy to Staging` and `Deploy to Production` jobs using the `staging` and `production` GitHub environments.
4. **Target Runtime:** Nginx (`infra/nginx/shopnest.conf`) serves static frontend assets from `/opt/shopnest/current/frontend/dist`, proxies `/api/` and `/health` requests to the Node.js backend service, and pairs the backend with PostgreSQL initialized via `infra/db/init.sql`.

## Deployment, Health Checks & Rollback

* **Deployment (`infra/scripts/deploy.sh`):** Places each release in `/opt/shopnest/releases/<sha>-<run_id>`, records the prior target in `previous`, updates the `current` symlink, installs production backend dependencies (`npm ci --omit=dev`), restarts the backend service, reloads Nginx, runs the `/health` check, and keeps the 5 most recent releases.
* **Health Check (`infra/scripts/health-check.sh`):** Polls the backend `/health` endpoint across configurable retries and delays until a healthy response is returned.
* **Rollback (`infra/scripts/rollback.sh` & Manual Dispatch):** If a deployment fails its `/health` check, `deploy.sh` automatically invokes `rollback.sh` to point `current` back to `previous`, restart the backend service, reload Nginx, and re-check `/health`. A manual rollback (`action: rollback`) can also be triggered for `staging` or `production` via the `CD` workflow's `workflow_dispatch` inputs.

## AI & Tooling Notes

AI assistance was used to help draft GitHub Actions workflow YAML, shell scripts for deployment/health/rollback, and documentation structure. Every workflow, script, and configuration was reviewed against repository paths and requirements, tested through GitHub Actions runs and pull requests, and refined iteratively before merging.

## Live Deployment

- **Live URL:** http://13.211.151.181

## Verification & Pipeline Screenshots

### Live Application
![Live Application](docs/screenshots/Screenshot%202026-11-20%20010848.png)

### Server & API Verification
![Server & API Verification](docs/screenshots/Screenshot%202026-11-20%20011126.png)

### GitHub Actions Runs
![GitHub Actions Runs](docs/screenshots/Screenshot%202026-11-20%20011208.png)
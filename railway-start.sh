#!/bin/sh
# Maps Railway's runtime variables onto Activepieces' settings, then hands
# over to the upstream entrypoint (docker-entrypoint.sh).
set -e

# Listen on the port Railway routes to (and health-checks).
export AP_PORT="${PORT:-${AP_PORT:-80}}"

# Public URL for redirects and webhooks: use the Railway domain unless set.
if [ -z "$AP_FRONTEND_URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export AP_FRONTEND_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

# Defaults from upstream's .env.example. Override any of them with a
# service variable of the same name.
export AP_ENVIRONMENT="${AP_ENVIRONMENT:-prod}"
export AP_CONTAINER_TYPE="${AP_CONTAINER_TYPE:-WORKER_AND_APP}"
export AP_EXECUTION_MODE="${AP_EXECUTION_MODE:-UNSANDBOXED}"
export AP_ENGINE_EXECUTABLE_PATH="${AP_ENGINE_EXECUTABLE_PATH:-dist/packages/engine/main.js}"
export AP_WEBHOOK_TIMEOUT_SECONDS="${AP_WEBHOOK_TIMEOUT_SECONDS:-30}"
export AP_TRIGGER_DEFAULT_POLL_INTERVAL="${AP_TRIGGER_DEFAULT_POLL_INTERVAL:-5}"
export AP_FLOW_TIMEOUT_SECONDS="${AP_FLOW_TIMEOUT_SECONDS:-600}"

# Railway's private network may resolve to IPv6 only; ask ioredis to try
# both address families unless the URL already says which one to use.
case "$AP_REDIS_URL" in
  "" | *family=*) ;;
  *\?*) export AP_REDIS_URL="${AP_REDIS_URL}&family=0" ;;
  *) export AP_REDIS_URL="${AP_REDIS_URL}?family=0" ;;
esac

cd /usr/src/app
exec ./docker-entrypoint.sh

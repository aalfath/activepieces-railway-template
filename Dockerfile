# Activepieces for Railway.
# Pinned by version and digest. To update, change both and add a CHANGELOG.md entry.
FROM activepieces/activepieces:0.93.0@sha256:151c2a4326c30a6a8086297136644da9b58072212c35bca7c87dcb5724e7d687

COPY railway-start.sh /usr/src/app/railway-start.sh
RUN chmod +x /usr/src/app/railway-start.sh

# tini reaps the worker's sandbox processes; the wrapper maps Railway's
# variables onto Activepieces' and then runs the upstream entrypoint.
ENTRYPOINT ["tini", "--", "/usr/src/app/railway-start.sh"]

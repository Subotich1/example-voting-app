#!/usr/bin/env bash
# End-to-end smoke test: start the whole stack, cast a vote,
# and confirm the worker wrote it to PostgreSQL.
set -euo pipefail

cd "$(dirname "$0")/.."

export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-e2e-$(date +%s)}"
COMPOSE="docker compose -p voting-e2e"

cleanup() { $COMPOSE down -v --remove-orphans >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "Starting stack..."
$COMPOSE up -d --build --wait --wait-timeout 180

echo "Checking result app responds..."
curl -fsS -o /dev/null http://localhost:8081/

echo "Casting a vote for option b..."
curl -fsS -o /dev/null -X POST --data "vote=b" http://localhost:8080/

echo "Waiting for the worker to store it..."
for i in $(seq 1 30); do
  count=$($COMPOSE exec -T db psql -U postgres -tAc \
    "SELECT COUNT(*) FROM votes WHERE vote = 'b';" 2>/dev/null || echo 0)
  if [ "${count:-0}" -ge 1 ]; then
    echo "PASS: vote stored (count=$count)"
    exit 0
  fi
  sleep 2
done

echo "FAIL: vote never reached the database"
$COMPOSE logs worker | tail -30
exit 1

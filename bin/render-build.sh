#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT/backend"
bundle install

cd "$ROOT"
npm run build

cd "$ROOT/backend"
bundle exec rails db:prepare

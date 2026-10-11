#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
gleam run -m lustre/dev --target erlang build app

mkdir -p .vercel/output/static
printf '{"version":3}\n' > .vercel/output/config.json
cp dist/index.html dist/app.js dist/app.css .vercel/output/static/

npx --yes vercel@latest deploy --prebuilt --prod "$@"

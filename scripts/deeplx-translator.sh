#!/usr/bin/env bash

die() {
  printf '\033[31m%s\033[0m\n' "$1"
  exit 1
}
trap 'kill $(jobs -p)' EXIT

command -v deeplx >/dev/null || die "deeplx is not installed"

deeplx&
sleep 0.1

query="$1"

request_data="$(jq -ncM \
  --arg text "$query" \
  --arg src_lang "auto" \
  --arg tgt_lang "RU" \
  '{"text": $text, "source_lang": $src_lang, "target_lang": $tgt_lang}')"

curl -s \
  -X POST http://localhost:1188/translate \
  -H "Content-Type: application/json" \
  -d "$request_data"


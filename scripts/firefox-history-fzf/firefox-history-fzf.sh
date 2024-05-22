#!/usr/bin/env bash

temp_file="$(mktemp --dry-run /tmp/places.sqlite.XXXXXX)"
cp ~/.mozilla/firefox/default/places.sqlite "$temp_file"

url="$(sqlite3 \
  -separator $'\t' \
  "$temp_file" \
  'SELECT title,moz_places.url FROM moz_places, moz_historyvisits WHERE moz_places.id = moz_historyvisits.place_id ORDER BY visit_date' |\
fzf \
  --tac \
  --delimiter $'\t' \
  --scheme history \
  --tiebreak begin,index \
  --no-hscroll | cut -f2 -d$'\t')"

rm "$temp_file" 

if [ -n "$url" ]; then
  hyprctl dispatch exec -- firefox "$url"
fi


#!/bin/sh

tab='	'
newline='
'

temp_file="$(mktemp --dry-run /tmp/places.sqlite.XXXXXX)"
cp ~/.mozilla/firefox/default/places.sqlite "$temp_file"

query='
SELECT
    title,
    moz_places.url
FROM
    moz_places,
    moz_historyvisits
WHERE
    moz_places.id = moz_historyvisits.place_id
ORDER BY
    visit_date;
'

result="$(
sqlite3 \
  -separator "$tab" \
  "$temp_file" \
  "$query" | \
awk \
  -F '\t' \
  -e '{title=(length($1) == 0)?"No title":$1; url=$2; printf "==> %s\n%s%c", title, url, 0}' | \
fzf \
  --read0 \
  --tac \
  --delimiter "$newline" \
  --scheme history \
  --tiebreak begin,index \
  --bind 'ctrl-y:execute-silent(echo {2..} | wl-copy -t "text/plain;charset=utf-8")' \
  --no-hscroll
)"

# killing sqlite3 before its output is fully read leaves -shm and -wal files in /tmp,
# use * expansion here to delete them as well
rm "${temp_file:?}"*

[ -z "$result" ] && exit
IFS="$newline"
set -- $result
url="$2"

open-in-browser "$url"


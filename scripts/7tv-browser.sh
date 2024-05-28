#!/usr/bin/env bash

# CONFIG
# how much emotes to fetch from 7tv
limit=100
# chafa image format, one of [iterm, kitty, sixels, symbols]
chafa_format="sixels"

die() {
  printf '\033[31m%s\033[0m\n' "$@"
  exit 1
}

depend() {
  if command -v "$1" >/dev/null 2>&1; then :; else
    die "$1 not installed"
  fi
}

depend "fzf"
depend "curl"
depend "chafa"
depend "magick"

cache_dir=~/.cache/7tv-browser
if [ ! -d "$cache_dir" ]; then
  mkdir -p "$cache_dir" || die "failed to create cache dir"
fi

# hell
request_body=\{\"operationName\":\"SearchEmotes\",\"variables\":\{\"query\":\"Business\",\"limit\":100,\"page\":1,\"sort\":\{\"value\":\"popularity\",\"order\":\"DESCENDING\"\},\"filter\":\{\"category\":\"TOP\",\"exact_match\":false,\"case_sensitive\":false,\"ignore_tags\":false,\"zero_width\":false,\"animated\":false,\"aspect_ratio\":\"\"\}\},\"query\":\"query\ SearchEmotes\(\$query:\ String\!,\ \$page:\ Int,\ \$sort:\ Sort,\ \$limit:\ Int,\ \$filter:\ EmoteSearchFilter\)\ \{\\n\ \ emotes\(query:\ \$query,\ page:\ \$page,\ sort:\ \$sort,\ limit:\ \$limit,\ filter:\ \$filter\)\ \{\\n\ \ \ \ count\\n\ \ \ \ items\ \{\\n\ \ \ \ \ \ id\\n\ \ \ \ \ \ name\\n\ \ \ \ \ \ state\\n\ \ \ \ \ \ trending\\n\ \ \ \ \ \ owner\ \{\\n\ \ \ \ \ \ \ \ id\\n\ \ \ \ \ \ \ \ username\\n\ \ \ \ \ \ \ \ display_name\\n\ \ \ \ \ \ \ \ style\ \{\\n\ \ \ \ \ \ \ \ \ \ color\\n\ \ \ \ \ \ \ \ \ \ paint_id\\n\ \ \ \ \ \ \ \ \ \ __typename\\n\ \ \ \ \ \ \ \ \}\\n\ \ \ \ \ \ \ \ __typename\\n\ \ \ \ \ \ \}\\n\ \ \ \ \ \ flags\\n\ \ \ \ \ \ host\ \{\\n\ \ \ \ \ \ \ \ url\\n\ \ \ \ \ \ \ \ files\ \{\\n\ \ \ \ \ \ \ \ \ \ name\\n\ \ \ \ \ \ \ \ \ \ format\\n\ \ \ \ \ \ \ \ \ \ width\\n\ \ \ \ \ \ \ \ \ \ height\\n\ \ \ \ \ \ \ \ \ \ __typename\\n\ \ \ \ \ \ \ \ \}\\n\ \ \ \ \ \ \ \ __typename\\n\ \ \ \ \ \ \}\\n\ \ \ \ \ \ __typename\\n\ \ \ \ \}\\n\ \ \ \ __typename\\n\ \ \}\\n\}\"\}

request_body="$(echo "$request_body" | jq -c ".variables.limit = ${limit}")"

export FZF_DEFAULT_COMMAND='true' # noop
export SHELL='bash'

fzf \
  --bind "ctrl-r:reload( \
    set -o pipefail; \

    query={q}; \
    if [ -z \"\$query\" ]; then exit 0; fi; \
    \
    request_body='$request_body'; \
    request_body=\"\$(echo \"\$request_body\" | jq -c \".variables.query = \\\"\$query\\\"\")\"; \
    \
    while IFS=\$'\t' read -r id name host filename; do \
      printf '%s\t%s\t%s\n' \"\$name\" \"\$id\" \"https:\${host}/\${filename}\"; \
    done < <(curl --fail -X POST -H 'Content-Type: application/json' -d \"\$request_body\" 'https://7tv.io/v3/gql' | jq -r '.data.emotes.items[] | \"\(.id)\t\(.name)\t\(.host.url)\t\(.host.files[-1].name)\"'); \
  )" \
  --bind "ctrl-y:execute-silent(id={2}; f=\"$cache_dir/\${id}.png\"; wl-copy <\"\$f\")" \
  --preview "
    set -o pipefail; \
    
    id={2}; \
    url={3}; \
    
    filetype=\"\${url##*.}\"; \
    
    if [ ! -f $cache_dir/\"\${id}.png\" ]; then \
      if curl -sS --fail-with-body \"\$url\" >/tmp/7tv-browser-curl-stdout; then \
        magick \"\$filetype\":/tmp/7tv-browser-curl-stdout'[0]' $cache_dir/\"\${id}.png\"; \
      else \
        cat /tmp/7tv-browser-curl-stdout; \
      fi; \
      rm /tmp/7tv-browser-curl-stdout; \
    fi; \

    chafa -f $chafa_format -O 9 --scale max --view-size \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} $cache_dir/\"\${id}.png\";
  " \
  --nth '1' \
  --with-nth '1' \
  --delimiter $'\t' \
  --header 'Type query and press CTRL+R to fetch results'


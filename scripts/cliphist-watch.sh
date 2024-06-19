#!/usr/bin/env bash

set -x; exec 1>~/aboba 2>&1
set -o pipefail

# silence all output
#exec 1>/dev/null

full_item="$(cliphist list | head -n1)"
item="$(echo "$full_item" | cut -d$'\t' -f2)"

delete_original() {
  echo "$full_item" | cliphist delete
}

decode() {
  echo "$full_item" | cliphist decode
}

length="${#item}"

# don't save 1 character long items
if [ "$length" -le 1 ]; then
  delete_original
# don't conduct further checks for small items to not waste resources grepping
elif [ "$length" -le 30 ]; then
  exit
fi

# convert images to png (seems to be supported by most apps)
# unnecessarily complicated regex because why the hell not
if ftype=$(echo "$item" | grep -oPe '^\[\[\ binary\ data\ [1-9][0-9]{0,2}\ (Mi|Ki)?B\ \K(bmp|jpeg)(?=\ [1-9][0-9]*x[1-9][0-9]*\ \]\]$)'); then
  if decode | convert "${ftype}:"- png:- | cliphist store; then
    delete_original
  fi
# download images that copy as funny html thingies and store an actual image instead
elif [[ "$item" = \<* ]]; then
  # this one is not that complicated but probably inefficient af
  url="$(decode | grep -oPe '<img .*src="\K(.+?)(?=")')"
  if [ -n "$url" ]; then
    # GOD I LOVE REGEX
    ftype=$(echo "$url" | grep -oPe '\?format=\K(jpeg|jpg|bmp|webp|png)(?=[\?&])') # this is needed because discord is retarted
    [ -z "$ftype" ] && ftype=$(echo "$url" | grep -oPe '\.\K(jpeg|jpg|bmp|webp|png)(?=\?)') # try to guess based on extension
    [ -n "$ftype" ] && ftype="${ftype}:"
    
    if curl -L --no-progress-meter --fail "$url" | convert "${ftype}"- png:- | cliphist store; then
      delete_original
    fi
  fi
fi


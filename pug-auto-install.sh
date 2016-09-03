#!/bin/bash

dest="$1"
url_prefix="$2"

if [[ -z "$dest" || -z "$url_prefix" ]]; then
  echo "** ERROR: Required arguments: <destination> <url prefix>"
  exit 1
fi

pug pug/pages -O "{base_url: '$url_prefix'}" --out "$dest/html" -w

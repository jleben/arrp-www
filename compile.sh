#!/bin/bash

src="$1"
url_prefix="$2"


if [[ -z "$src" || -z "$url_prefix" ]]; then
  echo "** ERROR: Required arguments: <source dir> <url prefix>"
  exit 1
fi

mkdir -p html
pug "$src/pug/pages" -O "{base_url: '$url_prefix'}" --out html

echo "$url_prefix" > url_prefix

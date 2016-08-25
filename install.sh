#!/bin/bash

dest="$1"

if [[ -z "$dest" ]]; then
  echo "Missing argument: Destination."
  exit 1
fi

mkdir -p "$dest/arrp"
cp "arrp/generic_main.cpp" "arrp/generic_printer.hpp" "$dest/arrp"

mkdir -p "$dest/cgi"
cp "cgi/arrp-code-post.sh" "$dest/cgi"

mkdir -p "$dest/content/html"
cp "content/html/index.html" "$dest/content/html"

mkdir -p "$dest/content/cgi"
cp "content/cgi/arrp-code-post-entry.sh" "$dest/content/cgi"

mkdir -p "$dest/requests"
chmod 777 "$dest/requests"

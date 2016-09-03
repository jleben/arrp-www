#!/bin/bash

dest="$1"
url_prefix="$2"

if [[ -z "$dest" || -z "$url_prefix" ]]; then
  echo "** ERROR: Required arguments: <destination> <url prefix>"
  exit 1
fi

mkdir -p "$dest/arrp"
cp "arrp/generic_main.cpp" "arrp/generic_printer.hpp" "$dest/arrp"

mkdir -p "$dest/cgi"
cp "cgi/arrp-code-post.sh" "$dest/cgi"
cp "cgi/arrp-code-post-entry.sh" "$dest/cgi"

mkdir -p "$dest/js"
cp "js/play.js" "$dest/js"

mkdir -p "$dest/css"
cp "css/style.css" "$dest/css"

mkdir -p "$dest/html"
pug pug/pages -O "{base_url: '/arrp'}" --out "$dest/html"

mkdir -p "$dest/apache"

function escape_sed_replacement {
  echo "$1" | sed -e "s/[/]/\\\&/g" -e "s/[.]/\\\&/g"
}

url_prefix_repl=$(escape_sed_replacement "$url_prefix")
file_prefix_repl=$(escape_sed_replacement "$dest")

echo "$url_prefix_repl"
echo "$file_prefix_repl"

sed \
  -e "s/{{url\-prefix}}/$url_prefix_repl/g" \
  -e "s/{{file\-prefix}}/$file_prefix_repl/g" \
  apache/arrp.conf.template > "$dest/apache/arrp.conf"

mkdir -p "$dest/requests"
chmod 777 "$dest/requests"

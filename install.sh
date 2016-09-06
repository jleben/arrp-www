#!/bin/bash

src="$1"
dest="$2"

if [[ -z "$src" || -z "$dest" ]]; then
  echo "** ERROR: Required arguments: <source> <destination>"
  exit 1
fi

url_prefix="$3"

if [[ -z "$url_prefix" ]]; then
  if [[ !(-e url_prefix) ]]; then
    echo "** ERROR: File 'url_prefix' does not exist, and url prefix not given on command line."
    exit 1
  fi
  url_prefix=$(cat url_prefix)
fi

if [[ -z "$url_prefix" ]]; then
  echo "** ERROR: File 'url_prefix' appears to be empty."
  exit 1
fi

mkdir -p "$dest/arrp"
cp "$src/arrp/generic_main.cpp" "$src/arrp/generic_printer.hpp" "$dest/arrp"

mkdir -p "$dest/cgi"
cp "$src/cgi/arrp-code-post.sh" "$dest/cgi"
cp "$src/cgi/arrp-code-post-entry.sh" "$dest/cgi"

mkdir -p "$dest/js"
cp "$src/js/play.js" "$dest/js"

mkdir -p "$dest/css"
cp "$src/css/style.css" "$dest/css"

mkdir -p "$dest/html"
cp -r html/* "$dest/html"

mkdir -p "$dest/apache"

function escape_sed_replacement {
  echo "$1" | sed -e "s/[/]/\\\&/g" -e "s/[.]/\\\&/g"
}

url_prefix_repl=$(escape_sed_replacement "$url_prefix")
file_prefix_repl=$(escape_sed_replacement "$dest")

#echo "$url_prefix_repl"
#echo "$file_prefix_repl"

sed \
  -e "s/{{url\-prefix}}/$url_prefix_repl/g" \
  -e "s/{{file\-prefix}}/$file_prefix_repl/g" \
  "$src/apache/arrp.conf.template" > "$dest/apache/arrp.conf"

mkdir -p "$dest/requests"
chmod 777 "$dest/requests"

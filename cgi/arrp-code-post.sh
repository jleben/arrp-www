#!/bin/bash

root_dir=$1

function get_query_value {
  param=$1
  pattern="$param=([^?]+)"
  if [[ "$QUERY_STRING" =~ $pattern ]]; then
    query_value=${BASH_REMATCH[1]}
  else
    query_value=""
  fi
}

get_query_value out_count
output_count=$query_value

#echo "query: $QUERY_STRING"
#echo "out count: $output_count"
#exit 0

echo "Content-type: text/plain"
echo

tee > code.arrp

code_size=$(stat -c%s code.arrp)
code_size_limit=10000

if [[ $code_size -gt $code_size_limit ]]; then
  echo "Error: code size is limited to $code_size_limit bytes."
  exit 0
fi

arrp code.arrp --cpp arrp_program --cpp-namespace arrp 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

c++ -std=c++11 -g -O0 -I$root_dir/arrp -I. $root_dir/arrp/generic_main.cpp -o program 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

./program "$output_count" > output.log 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

cat output.log

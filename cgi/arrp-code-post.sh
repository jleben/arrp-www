#!/bin/bash

cd ../requests
root_dir="../"

echo "Content-type: text/plain"
echo

tee > code.arrp

$root_dir/arrp/arrp code.arrp --cpp kernel --cpp-namespace kernel 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

c++ -std=c++11 -I$root_dir/arrp -I. $root_dir/arrp/generic_main.cpp -o program 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

./program > output.log 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

cat output.log

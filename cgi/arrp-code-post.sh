
#!/bin/bash

echo "Content-type: text/html"
echo

if [ -z $arrp ]
then
  echo "Environment variable 'arrp' undefined"
  exit 0
fi

tee > code.arrp

$arrp code.arrp --cpp kernel --cpp-namespace kernel 2> errors.log

if [ $? != 0 ]
then
  cat errors.log
  exit 0
fi

c++ -std=c++11 -I../arrp -I. ../arrp/generic_main.cpp -o program 2> errors.log

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

#!/bin/bash

#request_dir=$(echo "$REMOTE_ADDR" | xxd -pu)
#if [ $? != 0 ]; then
  #exit 1
#fi

#cd ../requests && \
#mkdir $request_dir && \
#cd $request_dir

PATH=""

if [[ "$REQUEST_METHOD" != "POST" ]]; then
  echo "Content-type: text/plain"
  echo
  echo "Please use the POST method to post some Arrp code."
  exit 0
fi

source ../config/config.sh

cd ../requests

if [ $? != 0 ]; then
  exit 1
fi

# Lock

../config/lock_requests || exit 1

# Process request

bash "../cgi/arrp-code-post.sh" "../"


#Unlock

../config/unlock_requests

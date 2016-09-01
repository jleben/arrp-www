#!/bin/bash

#request_dir=$(echo "$REMOTE_ADDR" | xxd -pu)
#if [ $? != 0 ]; then
  #exit 1
#fi

#cd ../requests && \
#mkdir $request_dir && \
#cd $request_dir

PATH=""

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

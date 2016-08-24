#!/bin/bash

#request_dir=$(echo "$REMOTE_ADDR" | xxd -pu)
#if [ $? != 0 ]; then
  #exit 1
#fi

#cd ../requests && \
#mkdir $request_dir && \
#cd $request_dir

cd ../requests

if [ $? != 0 ]; then
  exit 1
fi

# Lock

#../local/lock

if [[ -n $(which lockfile-create) ]]; then
    lockfile-create --lock-name request.lock --retry 1 || exit 1
elif [[ -n $(which lockfile) ]]; then
    lockfile -r 1 request.lock || exit 1
else
    exit 1
fi

# Process request

bash "../cgi/arrp-code-post.sh" "../"


#Unlock

#../local/unlock
rm -f request.lock

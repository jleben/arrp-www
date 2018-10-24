ARG ALPINE_DIGEST=sha256:13e33149491ce3a81a82207e8f43cd9b51bf1b8998927e57b1c2b53947961522

FROM alpine@${ALPINE_DIGEST} as builder
RUN apk add cmake make build-base git linux-headers

RUN mkdir -p /opt/build/

# Build Poco

RUN cd /opt/build && git clone --branch poco-1.9.0-release https://github.com/pocoproject/poco.git
RUN mkdir /opt/build/poco/cmake-build && cd /opt/build/poco/cmake-build && \
    cmake -D ENABLE_CRYPTO=OFF -D ENABLE_DATA=OFF -D ENABLE_ENCODINGS=OFF \
    -D ENABLE_JSON=OFF -D ENABLE_MONGODB=OFF -D ENABLE_PAGECOMPILER=OFF \
    -D ENABLE_PAGECOMPILER_FILE2PAGE=OFF \
    -D ENABLE_REDIS=OFF -D ENABLE_UTIL=OFF -D ENABLE_XML=OFF -D ENABLE_ZIP=OFF \
    .. && make install

# Build Arrp

RUN cd /opt/build && \
    git clone https://github.com/jleben/arrp.git && \
    cd /opt/build/arrp && \
    git checkout f61fff70a878fd0ae5989603c1e58d5978e51391 && \
    git submodule update --init --recursive

RUN apk add autoconf automake libtool gmp-dev

RUN cd /opt/build/arrp/extra/isl && \
    mkdir build && \
    ./autogen.sh && \
    ./configure --prefix=$(pwd)/build && \
    make install

# Use Clang from here on
# ENV CC=/usr/bin/clang CXX=/usr/bin/clang++

RUN mkdir /opt/build/arrp/build && cd /opt/build/arrp/build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/www/arrp .. && make install

# Build playground server

COPY . /opt/build/www
RUN mkdir /opt/build/www/build && cd /opt/build/www/build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/www/ .. && \
    cmake --build . && make install .


FROM node:10 as html-builder
RUN npm install -g pug pug-cli jstransformer-markdown-it
COPY ./pug /opt/build/pug/
# TODO: optional base url
RUN pug /opt/build/pug/pages -O "{base_url: ''}" --out /opt/build/html


FROM alpine@${ALPINE_DIGEST} as website
RUN apk add build-base nginx
# Copy Poco
COPY --from=builder /usr/local/lib/libPoco* /usr/local/lib/
 # Copy playground server
COPY --from=builder /opt/www /opt/www
COPY --from=builder /opt/build/www/js /opt/www/js
COPY --from=builder /opt/build/www/css /opt/www/css
COPY --from=builder /opt/build/www/arrp /opt/www/arrp
# Copy html
COPY --from=html-builder /opt/build/html /opt/www/html
# Install nginx configuration
RUN rm -r /etc/nginx/conf.d/*
COPY --from=builder /opt/build/www/build/nginx/arrp /etc/nginx/conf.d/arrp.conf
#RUN mkdir -p /etc/nginx/sites-enabled && ln -s /etc/nginx/sites-available/arrp /etc/nginx/sites-enabled/arrp
# TODO: Link nginx configuration
RUN mkdir /run/nginx

WORKDIR /opt/www/request

CMD nginx && /opt/www/server/arrp-server -d /opt/www/arrp

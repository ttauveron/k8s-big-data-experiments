FROM alpine:3.7

# the following ENV need to be present
ENV IAM_ROLE=none
ENV MOUNT_POINT=/var/s3
VOLUME /var/s3

ARG S3FS_VERSION=v1.79

RUN apk --update add fuse-dev alpine-sdk automake curl-dev php5 autoconf openssl-dev libxml2-dev libcrypto1.0 libcurl git bash

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git && \
cd s3fs-fuse && \
git checkout tags/${S3FS_VERSION} && \
./autogen.sh && \
./configure --prefix=/usr && \
make && \
make install && \
rm -rf /var/cache/apk/*

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php5", "-S", "0.0.0.0:80","-t","/var/s3"]

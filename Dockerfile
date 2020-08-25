ARG IMAGE_REPOSITORY=registry.hub.docker.com/library
ARG IMAGE_NAME=openjdk
ARG IMAGE_TAG=latest
FROM $IMAGE_REPOSITORY/$IMAGE_NAME:$IMAGE_TAG

ENV BANNER_MESSAGE="ADDING-CA" \
    CERTS_FOLDER=/certs \
    CERTS_EXTENSION="pem" \
    KEYTOOL_BIN=/usr/java/latest/bin/keytool \
    CACERT_PATH=/usr/java/latest/lib/security/cacerts \
    CACERT_PASS='changeit' \
    CACERT_DEST=/cacert

ADD ./assets /assets

RUN chmod +x /assets/docker-entrypoint \
&&  source /etc/os-release \
&&  yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION%.*}.noarch.rpm \
&&  yum -y install banner \
&&  mkdir -p ${CERTS_FOLDER} \
&&  mkdir -p ${CACERT_DEST}

ENTRYPOINT ["/assets/docker-entrypoint"]

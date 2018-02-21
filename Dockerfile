ARG RUBY_VERSION=2.5.0
ARG NODE_VERSION=9.5.0
ARG BUNDLER_VERSION=1.16.1

FROM ruby:${RUBY_VERSION}-stretch

ARG RUBY_VERSION
ARG NODE_VERSION
ARG BUNDLER_VERSION

LABEL maintainer="Logan Mzz"

LABEL org.ruby-lang.version="${RUBY_VERSION}"
LABEL io.bundler.version="${BUNDLER_VERSION}"
LABEL org.nodejs.version="${NODE_VERSION}"

# UTF-8 (see https://github.com/jekyll/jekyll/issues/4268#issuecomment-167406574)
RUN  apt-get update \
  && apt-get install -y locales \
  && rm -rf /var/lib/apt/lists/* \
  && dpkg-reconfigure locales \
  && locale-gen C.UTF-8 \
  && /usr/sbin/update-locale LANG=C.UTF-8 \
  && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
  && locale-gen

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Ruby gems
ENV BUNDLE_PATH=/data/.gem

ENV GEM_HOME=/data/.gem

ENV PATH="/data/.gem/bin:${PATH}"

RUN gem install bundler -v "${BUNDLER_VERSION}"


# Node (see https://github.com/nodejs/docker-node/blob/master/9/stretch/Dockerfile)
  # gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" || \
    gpg --keyserver hkp://keyserver.pgp.com:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

# ENV NODE_VERSION ${NODE_VERSION}

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV HOME /data

WORKDIR /data

EXPOSE 4000

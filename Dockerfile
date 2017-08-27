ARG UBUNTU_VERSION=latest

FROM gzdoompiler:${UBUNTU_VERSION}

#ENV SOURCE_HOME=/qwerty/

ENV GIT_LINK=git://github.com/coelckers/gzdoom.git

ENV FMOD_LINK=https://zdoom.org/files/fmod/fmodapi44464linux.tar.gz

WORKDIR /GZDOOM

COPY fmodapi42636linux.tar.gz /GZDOOM
COPY compiletools/compile.sh /GZDOOM

#CMD ["/GZDOOM/compile.sh", "<SOURCE_HOME>", "$GIT_LINK", "$FMOD_LINK" "-DNO_FMOD=OFF"]

ENTRYPOINT ["./compile.sh", "-DNO_FMOD=OFF"]


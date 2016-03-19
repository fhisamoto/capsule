FROM ruby:2.3
MAINTAINER Fabio Hisamoto <fhisamoto@gmail.com>

WORKDIR /tmp
RUN \
  wget -O cf-cli-installer.deb "https://cli.run.pivotal.io/stable?release=debian64&version=6.16.1&source=github-rel" && \
  dpkg -i cf-cli-installer.deb && \
  rm cf-cli-installer.deb && \
  cf install-plugin -f https://static-ice.ng.bluemix.net/ibm-containers-linux_x64

WORKDIR /

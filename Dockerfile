FROM debian:wheezy
MAINTAINER Tomasz Gaweda

ENV http_proxy http://172.17.42.1:8080/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN    apt-get update && apt-get -y install wget                     \
	&& wget -q http://172.17.42.1:9090/dock.6.6_source.tar.gz        \
	&& wget -q http://172.17.42.1:9090/docker-dock6/dock_install.sh \
	&& bash dock_install.sh dock*_source.tar.gz                     \
	&& rm -f dock*_source.tar.gz

CMD ["/bin/bash"]

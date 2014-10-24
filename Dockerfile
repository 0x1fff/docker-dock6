FROM ubuntu:14.10
MAINTAINER Tomasz Gaweda
#ENV http_proxy http://172.17.42.1:8080/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV DOCK6_HOME /home/dock6
RUN useradd -d ${DOCK6_HOME} -m -s /bin/bash dock6
COPY dock.6.6_source.tar.gz ${DOCK6_HOME}/dock.6.6_source.tar.gz
COPY dock6_install.sh ${DOCK6_HOME}/dock6_install.sh
RUN cd ${DOCK6_HOME} && bash ./dock6_install.sh dock.6.6_source.tar.gz

RUN chown -R dock6 ${DOCK6_HOME}

#USER dock6

CMD ["/bin/bash"]

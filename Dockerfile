# Pull base image.
FROM java:8-jre

ENV ES_PKG_NAME elasticsearch-1.7.1
ENV KIB_PKG_NAME kibana-4.1.2-linux-x64

# Install Elasticsearch.
RUN \
  cd / && \
  wget https://download.elastic.co/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch
# instal plugins
RUN sh /elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf/v1.5.7
RUN \
  cd / && \
  wget https://download.elastic.co/kibana/kibana/$KIB_PKG_NAME.tar.gz && \
  tar xvzf $KIB_PKG_NAME.tar.gz && \
  rm -f $KIB_PKG_NAME.tar.gz && \
  mv /$KIB_PKG_NAME /kibana

#install supervisor
RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p \
  /var/lock/elasticsearch /var/run/elasticsearch /var/log/elasticsearch \
  /var/run/supervisor /var/log/supervisor \
  /var/lock/kibana /var/run/kibana /var/log/kibana

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Define working directory.
WORKDIR /data

EXPOSE 9003 9200 9300 5601

ENTRYPOINT ["/usr/bin/supervisord"]

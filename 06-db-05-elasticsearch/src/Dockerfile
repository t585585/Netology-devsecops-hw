FROM centos:7

ENV PATH=/usr/lib:/usr/lib/jvm/jre-11/bin:$PATH JAVA_HOME=/opt/elasticsearch-8.0.1/jdk/ ES_HOME=/opt/elasticsearch-8.0.1

RUN yum install wget -y \
    && yum install perl-Digest-SHA -y \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 \
    && shasum -a 512 -c elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 \ 
    && tar -C /opt -xzf elasticsearch-8.0.1-linux-x86_64.tar.gz \
    && rm elasticsearch-8.0.1-linux-x86_64.tar.gz\
    && rm elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 \
    && groupadd elasticsearch \
    && useradd -g elasticsearch elasticsearch \
    && mkdir /var/lib/elasticsearch \
    && mkdir /var/log/elasticsearch \
    && mkdir /opt/elasticsearch-8.0.1/snapshots \
    && chown elasticsearch:elasticsearch /var/lib/elasticsearch \
    && chown elasticsearch:elasticsearch /var/log/elasticsearch \
    && chown -R elasticsearch:elasticsearch /opt/elasticsearch-8.0.1/
    
ADD elasticsearch.yml /opt/elasticsearch-8.0.1/config/
    
USER elasticsearch
CMD ["/usr/sbin/init"]
CMD ["/opt/elasticsearch-8.0.1/bin/elasticsearch"]
FROM java:8

ADD spark-2.3.0-bin-custom-spark.tgz /opt

ENV SPARK_HOME=/opt/spark-2.3.0-bin-custom-spark

RUN wget http://archive.apache.org/dist/incubator/livy/0.5.0-incubating/livy-0.5.0-incubating-bin.zip -P /opt && \
    unzip /opt/livy-0.5.0-incubating-bin.zip -d /opt && \
    rm /opt/livy-0.5.0-incubating-bin.zip && \
    mkdir /opt/livy-0.5.0-incubating-bin/logs

RUN ln -s /opt/spark* /opt/spark && \
    ln -s /opt/livy* /opt/livy

EXPOSE 8998 8080 6066 7077

ADD livy.conf /opt/livy-0.5.0-incubating-bin/conf
ADD entrypoint.sh /entrypoint.sh

ENV PATH="/opt/livy/bin:${PATH}"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["livy-server"]

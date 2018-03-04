FROM java:8

ARG AWS_JAVA_SDK_VERSION=1.7.4
ARG HADOOP_AWS_VERSION=2.7.3

ADD spark-2.3.0-bin-custom-spark.tgz /opt

ENV SPARK_HOME=/opt/spark-2.3.0-bin-custom-spark

RUN wget http://archive.apache.org/dist/incubator/livy/0.5.0-incubating/livy-0.5.0-incubating-bin.zip -P /opt && \
    unzip /opt/livy-0.5.0-incubating-bin.zip -d /opt && \
    rm /opt/livy-0.5.0-incubating-bin.zip && \
    mkdir /opt/livy-0.5.0-incubating-bin/logs

RUN ln -s /opt/spark* /opt/spark && \
    ln -s /opt/livy* /opt/livy

RUN mkdir -p /opt/spark/extras && \
    wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/$AWS_JAVA_SDK_VERSION/aws-java-sdk-$AWS_JAVA_SDK_VERSION.jar -P /opt/spark/extras && \
    wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar -P /opt/spark/extras

EXPOSE 8998 8080 6066 7077

ADD livy.conf /opt/livy-0.5.0-incubating-bin/conf
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD entrypoint.sh /entrypoint.sh


ENV PATH="/opt/livy/bin:${PATH}"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["livy-server"]

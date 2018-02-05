FROM java:8

ARG SPARK_VERSION=2.2.1
ARG AWS_JAVA_SDK_VERSION=1.7.4
ARG HADOOP_AWS_VERSION=2.7.5
ARG LIVY_RELEASE=0.4.0-incubating


#RUN wget -P /opt https://www.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.7.tgz && \
# cd /opt && \
# tar xvzf spark-$SPARK_VERSION-bin-hadoop2.7.tgz && \
# rm spark-$SPARK_VERSION-bin-hadoop2.7.tgz


ADD spark-$SPARK_VERSION-bin-hadoop2.7.tgz /opt

RUN ln -s /opt/spark* /opt/spark && \
    mkdir -p /opt/spark/extras && \
    wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/$AWS_JAVA_SDK_VERSION/aws-java-sdk-$AWS_JAVA_SDK_VERSION.jar -P /opt/spark/extras && \
    wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar -P /opt/spark/extras

ENV SPARK_HOME=/opt/spark

RUN wget -P /opt http://mirror.its.dal.ca/apache/incubator/livy/${LIVY_RELEASE}/livy-${LIVY_RELEASE}-bin.zip

RUN unzip /opt/livy-${LIVY_RELEASE}-bin.zip -d /opt && \
    rm /opt/livy-${LIVY_RELEASE}-bin.zip && \
    ln -sf /opt/livy-${LIVY_RELEASE}-bin /opt/livy && \
    mkdir /opt/livy/logs

ADD entrypoint.sh /entrypoint.sh
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD livy.conf /opt/livy/conf/livy.conf
ADD start-common.sh /start-common.sh
ADD start-master.sh /start-master.sh
ADD start-worker.sh /start-worker.sh
ADD spark-env.sh /opt/spark/conf/spark-env.sh

ENV PATH="/opt/spark/bin:${PATH}"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]

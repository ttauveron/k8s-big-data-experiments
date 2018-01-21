FROM openjdk:8-jre-alpine

ARG SPARK_VERSION=2.2.1
ARG AWS_JAVA_SDK_VERSION=1.7.4
ARG HADOOP_AWS_VERSION=2.7.5
ARG USER_HOME_DIR="/root"

#TODO download spark instead of adding it
ADD spark-$SPARK_VERSION-bin-hadoop2.7.tgz $USER_HOME_DIR

RUN ln -s $USER_HOME_DIR/spark* $USER_HOME_DIR/spark && \
    mkdir -p $USER_HOME_DIR/spark/extras && \
    wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/$AWS_JAVA_SDK_VERSION/aws-java-sdk-$AWS_JAVA_SDK_VERSION.jar -P $USER_HOME_DIR/spark/extras && \
    wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar -P $USER_HOME_DIR/spark/extras

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

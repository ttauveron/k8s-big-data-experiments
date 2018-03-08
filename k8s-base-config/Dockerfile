FROM openjdk:8

COPY target/demo-0.0.1-SNAPSHOT.jar /app.jar
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8888/tcp

ENTRYPOINT ["/entrypoint.sh"]
RUN ["java", "-jar", "/app.jar"]
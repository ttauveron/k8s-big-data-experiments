FROM openjdk:8
COPY target/demo-0.0.1-SNAPSHOT.jar /app.jar
EXPOSE 8888/tcp
ENTRYPOINT ["java", "-jar", "/app.jar"]
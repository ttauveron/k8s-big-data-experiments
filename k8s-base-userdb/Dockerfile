FROM openjdk:8
COPY target/demo-0.0.1-SNAPSHOT.jar /app.jar
EXPOSE 12679/tcp
ENTRYPOINT ["java", "-jar", "/app.jar"]
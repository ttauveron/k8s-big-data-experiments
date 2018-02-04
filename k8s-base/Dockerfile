FROM openjdk:8
COPY classes/artifacts/demo_jar/demo.jar /app.jar
EXPOSE 8080/tcp
ENTRYPOINT ["java", "-jar", "/app.jar"]
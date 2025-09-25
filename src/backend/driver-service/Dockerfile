FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/driver-service-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
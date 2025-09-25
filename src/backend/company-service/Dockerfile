FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/company-service-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8083

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
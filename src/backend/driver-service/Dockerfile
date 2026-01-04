FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

COPY target/driver-service-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
# Backend - Spring Boot (Java 17)
# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Download dependencies first (layer caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn package -DskipTests -B

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine

# Create a non-root user and group for security
RUN addgroup -S begroup && adduser -S beuser -G begroup

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

# Change ownership of the app directory to the new user
RUN chown -R beuser:begroup /app

# Switch to the non-root user
USER beuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

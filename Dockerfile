FROM maven:3.9.6-eclipse-temurin-17 as build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copier le jar
COPY --from=build /app/target/*.jar app.jar

# Copier le fichier YAML de configuration
COPY --from=build /app/src/main/resources/application.yml ./config/application.yml

# Activer le profil par défaut si nécessaire (pas indispensable ici)
ENV SPRING_PROFILES_ACTIVE=default

# Démarrage
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.config.location=classpath:/config/application.yml"]

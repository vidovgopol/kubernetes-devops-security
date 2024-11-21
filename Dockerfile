FROM openjdk:8-jdk-alpine
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup -S pipline && adduser -S k8s-pipline -G pipline
COPY ${JAR_FILE} /home/k8s-pipline/app.jar
ENTRYPOINT ["java","-jar","/home/k8s-pipline/app.jar"]
FROM openjdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN apk add --no-cache shadow && \
    addgroup -S pipeline && \
    adduser -S k8s-pipeline -G pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
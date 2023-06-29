pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('test phase') {
            steps {
              sh "mvn test"
            }
            post {
              always{
                junit "target/sunfire-reports/*.xml"
                jacoco execPattern: "target/jacoco.exec"
              }
            }
        }    
    
      stage('image push') {
            steps {
              withDockerRegistry([credentialsID:'dockerhub', url:""]) {
                sh "printenv"
                sh 'docker build -t kumard31/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push kumard31/numeric-app:""$GIT_COMMIT""'
              }
            }
      }
  }        
}

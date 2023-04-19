pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true //so that they can be downloaded later. Artefact is genertated here.
            }
        }   
      stage('Unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }   
      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]){
                sh "printenv"
                sh "docker build -t resonantitsolutions/numeric-app:'$GIT_COMMIT' ."
                sh "docker push resonantitsolutions/numeric-app:'$GIT_COMMIT'"
              }
            }
        }   
    }
}

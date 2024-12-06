pipeline {
  agent any

  stages {
    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
      }
    }

    stage('Unit testing') {
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

    stage('SonarQube Analysis') {
      steps {
     
          sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=devsecops-numeric-application -Dsonar.host.url=http://devsecops-demo.eastus.cloudapp.azure.com:9000 -Dsonar.login=sqa_a14d0e882c2f317164d9e58c2090c9474d88259b '
      }
    }

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'docker build -t abhix01/numeric-app:${GIT_COMMIT} .'
          sh 'docker push abhix01/numeric-app:${GIT_COMMIT}'
        }
      }
    }

    stage('K8S Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#abhix01/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml"
        }
      }
    }
  }
}

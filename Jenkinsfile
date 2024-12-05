pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' ///
            }
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
                def mvn = tool 'Default Maven';
                withSonarQubeEnv() {
                  sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=devsecops-numeric-application -Dsonar.projectName='devsecops-numeric-application'"
                }
          }


        
            stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'sudo docker build -t abhix01/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push abhix01/numeric-app:""$GIT_COMMIT""'
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


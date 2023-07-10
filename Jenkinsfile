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
                junit "target/surefire-reports/*.xml"
                jacoco execPattern: "target/jacoco.exec"
              }
            }
        }   

      stage('PIT phase') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'

              }
            }
      } 
    
      stage('image push') {
            steps {
              withDockerRegistry([credentialsId:'dockerhub', url:""]) {
                sh "printenv"
                sh 'docker build -t kumard31/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push kumard31/numeric-app:""$GIT_COMMIT""'
              }
            }
      }

      stage('k8s deployment') {
            steps {
              withKubeConfig([credentialsId:'kubeconfig']) {
                sh "sed -i 's#replace#kumard31/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh 'kubectl apply -f k8s_deployment_service.yaml'
              }
            }
      }
  }        
}

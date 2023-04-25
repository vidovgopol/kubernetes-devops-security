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

      stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
        }   
      stage("build & SonarQube analysis-SAST") {
        steps {
          withSonarQubeEnv('CloudOps SonarQube') {
            sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://cloudops.eastasia.cloudapp.azure.com:9000"
          }
        }
      }

      // stage("build & SonarQube analysis-SAST") {
      //   agent any
      //   steps {
      //     // withSonarQubeEnv('CloudOps SonarQube') {
      //     //   sh 'mvn clean package sonar:sonar'
      //     // }
      //     sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://cloudops.eastasia.cloudapp.azure.com:9000  -Dsonar.token='$SonarQubeSecret'"
      //   }
      // }
      // stage("Quality Gate") {
      //   steps {
      //     timeout(time: 1, unit: 'HOURS') {
      //       waitForQualityGate abortPipeline: true
      //     }
      //   }
      // }
      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]){
                sh "printenv"
                // Run These two below commands into the VM first to get docker login successful  
                // sudo usermod -aG docker jenkins
                // sudo chmod 666 /var/run/docker.sock
                sh "docker build -t resonantitsolutions/numeric-app:'$GIT_COMMIT' ."
                sh "docker push resonantitsolutions/numeric-app:'$GIT_COMMIT'"
              }
            }
        }   

      stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#resonantitsolutions/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
              }
            }
        }   

    }
}
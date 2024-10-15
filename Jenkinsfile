pipeline {
  agent any

  stages {

    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and Jacoco') {
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
    // Add PIT Mutation Test
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
    stage('Vulnerability Tests') {
      steps {
        sh "mvn dependency-check:check"
      }
      post {
        always {
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }
    }
    
     // For default
    // stage('SonarQube') {
    //   steps {
    //     sh "mvn clean verify sonar:sonar \
    //         -Dsonar.projectKey=devsecops-numeric-application \
    //         -Dsonar.host.url=https://30012-port-1e4dabbbcbcf4fbb.labs.kodekloud.com \
    //         -Dsonar.login=sqp_752334d1feca934931e032a5799dc5865ffef3c2"
    //   }
    // }
    // For custom  Quality Gates
    stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh "mvn sonar:sonar \
              -Dsonar.projectKey=devsecops-numeric-application \
              -Dsonar.host.url=<sonarqube-server-url>"
      }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }
    stage('Docker image build and push') {
      steps {
        sh 'docker build -t docker-registry:5000/java-app:latest .'
        sh 'docker push docker-registry:5000/java-app:latest'
       }
    }
// Tạo stage cho k8s với lệnh sed sẽ repalace chữ REPLACE_ME 
// thành imag chúng ta đã build ở thêm và apply file.yml ở Jenkins server 
    stage('K8s deployemt') {
      steps {
        sh "sed -i 's#REPLACE_ME#docker-registry:5000/java-app:latest#g' k8s_deployment_service.yaml"
        sh 'kubectl apply -f k8s_deployment_service.yaml'
       }
     }

   }
 }

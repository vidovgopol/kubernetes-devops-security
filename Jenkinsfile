pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "yinko2/numeric-app:${GIT_COMMIT}"
    devNamespace = "dev"
    applicationURL="https://devsecops.aungmyatkyaw.site"
    applicationURI="/increment/99"
  }

  stages {
    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar' //so that they can be downloaded later
      }
    }

    stage('Unit Tests - JUnit and JaCoCo') {
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

    stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh "mvn sonar:sonar -Dsonar.analysis.mode=publish" 
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }

    stage('Vulnerability Scan - Docker') {
      steps {
        parallel(
        	"Dependency Scan": {
        		sh "mvn dependency-check:check"
          },
          "Trivy Scan":{
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest":{
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
          }   	
      	)
      }
      post { 
        always { 
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "dockerhub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t ""$imageName"" .'
          sh 'docker push ""$imageName""'
        }
      }
    }

    // stage('K8S Deployment - DEV') {
    //   steps {
    //     parallel(
    //       "Deployment": {
    //         withKubeConfig([credentialsId: 'kubeconfig']) {
    //           sh "bash k8s-deployment.sh"
    //         }
    //       },
    //       "Rollout Status": {
    //         withKubeConfig([credentialsId: 'kubeconfig']) {
    //           sh "bash k8s-deployment-rollout-status.sh"
    //         }
    //       }
    //     )
    //   }
    // }

  }
}

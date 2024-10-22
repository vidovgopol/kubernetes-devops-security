pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' ///
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
            stage('Docker Build and Push') {
          steps {
            
              sh 'printenv'
              sh 'sudo docker build -t abhix01/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push abhix01/numeric-app:""$GIT_COMMIT""'
            }
          }
        }
        } 
}  
}  

    


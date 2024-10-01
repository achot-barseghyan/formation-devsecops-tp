pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        } 
      stage('UNIT test & jacoco ') {
            steps {
              sh "mvn test"
            }  
        }
      stage('sonarcube') {
            steps {
              withCredentials([string(credentialsId: 'sonar_token', variable: 'TOKEN')])
              sh "mvn clean verify sonar:sonar \
                  -Dsonar.projectKey=maven-jenkins-pipeline \
                  -Dsonar.projectName='maven-jenkins-pipeline' \
                  -Dsonar.host.url=http://myvmtp.eastus.cloudapp.azure.com:9000 \
                  -Dsonar.token=${TOKEN}"
            }
          }
      
  }
  post { //create report
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            
        }
  }
}
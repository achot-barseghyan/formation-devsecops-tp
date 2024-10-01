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
          stage('Sonarqube Analysis - SAST') {
          steps {
            withSonarQubeEnv('SonarQube') {
                sh "mvn sonar:sonar \
                    -Dsonar.projectKey=maven-jenkins-pipeline \
                    -Dsonar.host.url=http://myvmtp.eastus.cloudapp.azure.com:9999/"
            }
          }
      }
      stage("Quality gate") {
            steps {
                waitForQualityGate abortPipeline: true
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
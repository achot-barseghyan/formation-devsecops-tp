pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
        //--------------------------
      stage('UNIT test & jacoco ') {
            steps {
              sh "mvn test"
            }  
        }
        //--------------------------
          stage('Sonarqube Analysis - SAST') {
          steps {
            withSonarQubeEnv('SonarQube') {
                sh "mvn sonar:sonar \
                    -Dsonar.projectKey=maven-jenkins-pipeline \
                    -Dsonar.host.url=http://myvmtp.eastus.cloudapp.azure.com:9999/"
            }
          }
      }
      //--------------------------
      stage('Vulnerability Scan owasp - dependency-check') {
        steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh "mvn dependency-check:check"
            }
          }
      }
      //--------------------------
    stage('Docker Build and Push') {
      steps {
        withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD', variable: 'DOCKER_HUB_PASSWORD')]) {
          sh 'sudo docker login -u haid3s -p $DOCKER_HUB_PASSWORD'
          sh 'printenv'
          sh 'sudo docker build -t haid3s/devops-app:""$GIT_COMMIT"" .'
          sh 'sudo docker push haid3s/devops-app:""$GIT_COMMIT""'
        }
 
      }
    }
    //--------------------------
    stage('Vulnerability Scan - Docker Trivy') {
       steps {
	        withCredentials([string(credentialsId: 'trivy_token_achraf', variable: 'TOKEN')]) {
			 catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                 sh "sed -i 's#token_github#${TOKEN}#g' trivy-image-scan.sh"
                 sh "sudo bash trivy-image-scan.sh"
	       }
		}
       }
     }
    //--------------------------
    stage('Deployment Kubernetes  ') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#haid3s/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh 'kubectl apply -f k8s_deployment_service.yaml'
        }
      }
    }
  }
  post { //create report
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
  }
}
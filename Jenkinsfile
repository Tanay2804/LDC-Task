pipeline{
     agent any
     
     tools{
         jdk 'jdk-17'
         nodejs 'node-16'
     }
     environment {
         SCANNER_HOME=tool 'sonarqube-scanner'
     }
     
     stages {
         stage('Clean Workspace'){
             steps{
                 cleanWs()
             }
         }
         stage('Checkout from Git'){
             steps{
                 git branch: 'main', url: 'https://github.com/Tanay2804/LDC-Task.git/'
             }
         }
         stage("Sonarqube Analysis "){
             steps{
                 withSonarQubeEnv('SonarQube-Server') {
                     sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=CICD \
                     -Dsonar.projectKey=CICD '''
                 }
             }
         }
         stage("Quality Gate"){
            steps {
                 script {
                     waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token' 
                 }
             } 
         }
         stage('Install Dependencies') {
             steps {
                 sh "cd web && npm install"
             }
         }
         stage('TRIVY FS SCAN') {
             steps {
                 sh "trivy fs . > trivyfs.txt"
             }
         }
          stage("Docker Build & Push"){
             steps{
                 script{
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){   
                       sh "docker build -t cicd ./web"
                       sh "docker tag cicd tanaytibrewal/cicd:latest"
                       sh "docker push tanaytibrewal/cicd:latest"
                     }
                 }
             }
         }
        //  stage("TRIVY"){
        //      steps{
        //          sh "trivy image tanaytibrewal/cicd:latest > trivyimage.txt" 
        //      }
        //  }
        //   stage('Deploy to Kubernets'){
        //      steps{
        //          script{
        //              dir('Kubernetes') {
        //                  kubeconfig(credentialsId: 'kubernetes', serverUrl: '') {
        //                  sh 'kubectl delete --all pods'
        //                  sh 'kubectl apply -f deployment.yml'
        //                  sh 'kubectl apply -f service.yml'
        //                  }   
        //              }   
        //          }
        //      }
        //  }



     }
 }

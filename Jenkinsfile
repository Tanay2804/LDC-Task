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
        stage("Deploy Container"){
            steps{
                script{
                    sh '''
                        # Check if container is running and stop/remove it
                        if [ $(docker ps -q -f name=cicd-app) ]; then
                            echo "Stopping running container..."
                            docker stop cicd-app
                        fi
                        
                        # Remove container if it exists (running or stopped)
                        if [ $(docker ps -aq -f name=cicd-app) ]; then
                            echo "Removing existing container..."
                            docker rm cicd-app
                        fi
                        
                        # Pull the latest image
                        echo "Pulling latest image..."
                        docker pull tanaytibrewal/cicd:latest
                        
                        # Run new container
                        echo "Starting new container..."
                        docker run -d --name cicd-app -p 3000:3000 tanaytibrewal/cicd:latest
                        
                        echo "Container deployed successfully!"
                    '''
                }
            }
        }
     }
}

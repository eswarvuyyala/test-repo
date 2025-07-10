pipeline {
    agent any

    environment {
        GIT_REPO    = 'https://github.com/eswarvuyyala/test-repo.git'
        SONAR_HOST  = 'http://13.201.203.112:9000'
        SONAR_PROJECT_KEY = 'test-repo'
        IMAGE_NAME  = 'test-repo-image'
        IMAGE_TAG   = "v1.0.${BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('SonarQube Scan') {
            environment {
                SONAR_TOKEN = credentials('new-test-nodejs') // Sonar token ID
            }
            steps {
                sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=${SONAR_HOST} \
                      -Dsonar.login=$SONAR_TOKEN
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def fullImage = "${IMAGE_NAME}:${IMAGE_TAG}"
                    echo "🧹 Cleaning up any old image: ${IMAGE_NAME}"

                    // Remove any image with the same name (if exists)
                    sh """
                        docker images -q ${IMAGE_NAME} | xargs -r docker rmi -f || true
                    """

                    echo "🐳 Building new Docker image: ${fullImage}"
                    sh "docker build -t ${fullImage} ."
                }
            }
        }
    }
}

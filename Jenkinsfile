pipeline {
    agent any

    environment {
        GIT_REPO           = 'https://github.com/eswarvuyyala/test-repo.git'
        SONAR_HOST         = 'http://13.201.203.112:9000'
        SONAR_PROJECT_KEY  = 'test-repo'
        IMAGE_NAME         = 'test-repo-image'
        IMAGE_TAG          = "v1.0.${BUILD_NUMBER}"
        FULL_IMAGE         = "${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('SonarQube Scan') {
            environment {
                SONAR_TOKEN = credentials('new-test-nodejs')
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
                    echo "📦 Checking for Dockerfile..."
                    sh "ls -l"
                    sh "test -f Dockerfile || { echo '❌ Dockerfile not found!'; exit 1; }"

                    echo "🧹 Removing old image if exists"
                    sh "docker images -q ${IMAGE_NAME} | xargs -r docker rmi -f || true"

                    echo "🐳 Building Docker image: ${FULL_IMAGE}"
                    sh "docker build -t ${FULL_IMAGE} ."
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    echo "🔍 Running Trivy scan..."
                    sh "trivy image --format table --severity HIGH,CRITICAL --output trivy-report.txt ${FULL_IMAGE}"
                }
            }
        }
    }
}

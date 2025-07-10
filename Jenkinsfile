pipeline {
    agent any

    environment {
        GIT_REPO           = 'https://github.com/eswarvuyyala/test-repo.git'
        SONAR_HOST         = 'http://13.201.203.112:9000'
        SONAR_PROJECT_KEY  = 'new-test-sonar'
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
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.host.url=${SONAR_HOST}'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🧹 Removing old image if it exists"
                    sh "docker images -q ${IMAGE_NAME} | xargs -r docker rmi -f || true"

                    echo "🐳 Building Docker image: ${FULL_IMAGE}"
                    sh "docker build -t ${FULL_IMAGE} ."
                }
            }
        }

        stage('Trivy Vulnerability Scan') {
            steps {
                script {
                    echo "🔍 Running Trivy image scan..."
                    sh "trivy image --format table --output trivy-report.txt --severity HIGH,CRITICAL ${FULL_IMAGE}"
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed. Please check the logs."
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
    }
}

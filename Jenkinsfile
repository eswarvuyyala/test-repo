pipeline {
    agent any

    environment {
        GIT_REPO           = 'https://github.com/eswarvuyyala/test-repo.git'
        SONAR_PROJECT_KEY  = 'new-test-sonar'
        SONAR_HOST         = 'http://13.201.203.112:9000'
        IMAGE_NAME         = 'test-repo-image'
        IMAGE_TAG          = "v1.0.${BUILD_NUMBER}"
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
                    sh """
                        mvn clean verify sonar:sonar \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.host.url=${SONAR_HOST}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🧹 Removing any old image (if exists)"
                    sh "docker rmi -f ${IMAGE_NAME}:${IMAGE_TAG} || true"

                    echo "🐳 Building Docker image"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                echo "🔍 Scanning Docker image with Trivy"
                sh "trivy image ${IMAGE_NAME}:${IMAGE_TAG} --format table --output trivy-report.txt"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}

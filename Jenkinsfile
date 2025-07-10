pipeline {
    agent any

    environment {
        GIT_REPO          = 'https://github.com/eswarvuyyala/test-repo.git'
        SONAR_PROJECT_KEY = 'new-test-sonar'
        SONAR_HOST        = 'http://13.201.203.112:9000'
        IMAGE_NAME        = 'new-test-sonar'
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

        stage('Bump Version') {
            steps {
                script {
                    def versionFile = 'version.txt'
                    def currentVersion = 'v1.0'

                    if (fileExists(versionFile)) {
                        currentVersion = readFile(versionFile).trim()
                        def (major, minor) = currentVersion.replace('v', '').tokenize('.').collect { it.toInteger() }
                        def newMinor = minor + 1
                        env.IMAGE_TAG = "v${major}.${newMinor}"
                    } else {
                        env.IMAGE_TAG = currentVersion
                    }

                    echo "🚀 New Docker image version: ${env.IMAGE_TAG}"
                    writeFile file: versionFile, text: "${env.IMAGE_TAG}"

                    // Commit new version back to repo
                    withCredentials([usernamePassword(credentialsId: 'git-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        sh """
                            git config user.name "jenkins"
                            git config user.email "jenkins@local"
                            git add ${versionFile}
                            git commit -m "🔖 Bump version to ${env.IMAGE_TAG}" || true
                            git push https://${GIT_USER}:${GIT_PASS}@github.com/eswarvuyyala/test-repo.git HEAD:main
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker rmi -f ${IMAGE_NAME}:${env.IMAGE_TAG} || true"
                sh "docker build -t ${IMAGE_NAME}:${env.IMAGE_TAG} ."
            }
        }

        stage('Trivy Scan Docker Image') {
            steps {
                sh "trivy image ${IMAGE_NAME}:${env.IMAGE_TAG} --format table --output trivy-report.txt"
            }
        }
    }

    post {
        success {
            echo "✅ Build completed successfully with image: ${IMAGE_NAME}:${env.IMAGE_TAG}"
        }
        failure {
            echo "❌ Build failed"
        }
    }
}

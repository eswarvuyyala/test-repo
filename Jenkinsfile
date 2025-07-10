pipeline {
    agent any

    environment {
        AWS_REGION     = 'ap-south-1'
        ECR_ACCOUNT_ID = '923687682884'
        ECR_REPO       = 'react-app'
        IMAGE_NAME     = 'react-app'
        VERSION        = "v1.0.${BUILD_NUMBER}"
        ECR_URI        = "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        ECR_IMAGE      = "${ECR_URI}:${VERSION}"
        GIT_REPO       = 'https://github.com/eswarvuyyala/react-app.git'
        K8S_NAMESPACE  = 'test-nodejs'
        K8S_DEPLOYMENT = 'react-app'
    }

    stages {
        stage('Clone Git Repo') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker rmi -f ${IMAGE_NAME} || true"
                    sh "docker build -t ${IMAGE_NAME} ."
                    sh "docker tag ${IMAGE_NAME}:latest ${ECR_IMAGE}"
                }
            }
        }

        stage('Trivy Scan Image') {
            steps {
                script {
                    echo "🔍 Running Trivy scan on ${ECR_IMAGE}"
                    sh "trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}"
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_CLI']]) {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
                    """
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh "docker push ${ECR_IMAGE}"
            }
        }

        stage('Wait for ECR Image Availability') {
            steps {
                script {
                    echo "⏳ Waiting for image ${ECR_IMAGE} to appear in ECR..."
                    def retries = 5
                    def found = false
                    for (int i = 0; i < retries; i++) {
                        def result = sh(
                            script: "aws ecr describe-images --repository-name ${ECR_REPO} --region ${AWS_REGION} --image-ids imageTag=${VERSION} || true",
                            returnStdout: true
                        ).trim()
                        if (result.contains("imageTag")) {
                            echo "✅ Image found in ECR!"
                            found = true
                            break
                        } else {
                            echo "🔁 Image not found, retrying in 10 seconds..."
                            sleep time: 10, unit: 'SECONDS'
                        }
                    }
                    if (!found) {
                        error "❌ Image ${ECR_IMAGE} not found in ECR after ${retries} attempts"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "🚀 Deploying ${ECR_IMAGE} to Kubernetes..."
                    sh """
                        kubectl set image deployment/${K8S_DEPLOYMENT} ${K8S_DEPLOYMENT}=${ECR_IMAGE} -n ${K8S_NAMESPACE}
                        kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
    }
}

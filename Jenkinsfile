pipeline {
    agent any

    environment {
        GIT_REPO    = 'https://github.com/eswarvuyyala/test-repo.git'
        SONAR_HOST  = 'http://13.201.203.112:9000'
        SONAR_PROJECT_KEY = 'test-repo'  // Update if needed
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('SonarQube Scan') {
            environment {
                SONAR_TOKEN = credentials('new-test-nodejs') // Jenkins credential ID
            }
            steps {
                sh """
                    sonar-scanner \
                      -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=${SONAR_HOST} \
                      -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }
    }
}

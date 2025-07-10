pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/eswarvuyyala/test-repo.git'
    }

    stages {
        stage('Clone Git Repo') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }
    }
}

stage('Clone Git Repo') {
    steps {
        git url: 'https://github.com/eswarvuyyala/test-repo.git', branch: 'main', credentialsId: 'git-credentials'
    }
}
apipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/eswarvuyyala/test-repo.git'
    }

    stages {
        stage('Clone Git Repo') {
            steps {
                git url: "${GIT_REPO}", branch: 'main', credentialsId: 'git-credentials'
            }
        }
    }
}

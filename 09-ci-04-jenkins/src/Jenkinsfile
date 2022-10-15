pipeline {
    agent {
        label 'linux'
    } 
    stages {
        stage('git pull') {
            steps {
                git branch: 'master', credentialsId: '1829e7da-eec6-4dfc-9465-a22c4a30691b', url: 'git@github.com:t585585/vector-role.git'
            }
        }
        stage('molecule test') {
            steps {
                sh 'molecule --version'
            }
        }
    }
}

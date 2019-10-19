pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'docker build -t hackheroes-server:$GIT_COMMIT .'
      }
    }
    stage('Deploy') {
      steps {
        sh 'docker service update hackheroes_server --image hackheroes-server:$GIT_COMMIT'
      }
    }
  }
}
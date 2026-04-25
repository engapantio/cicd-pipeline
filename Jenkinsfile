pipeline {
  agent any
  stages {
    stage('Build') {
      agent {
        docker {
          image 'node:18-alpine'
          args 'reuseNode true'
        }

      }
      steps {
        sh 'npm install'
      }
    }

    stage('Test') {
      agent {
        docker {
          image 'node:18-alpine'
          args 'reuseNode true'
        }

      }
      steps {
        sh 'npm test'
      }
    }

    stage('Docker build') {
      steps {
        sh 'docker build -t ${IMAGE_NAME}:v1.0 .'
      }
    }

    stage('Deploy') {
      steps {
        sh 'docker stop ${IMAGE_NAME} || true'
        sh 'docker rm ${IMAGE_NAME} || true'
        sh '''docker run -d --name ${IMAGE_NAME} \\
                        --expose ${PORT_HOST} \\
                        -p ${PORT_HOST}:${PORT_CONT} \\
                        ${IMAGE_NAME}:v1.0'''
      }
    }

  }
  environment {
    BRANCH = '"${env.BRANCH_NAME}"'
    IMAGE_NAME = '"${BRANCH == \'main\' ? \'nodemain\' : \'nodedev\'}"'
    PORT_HOST = 'PORT_HOST = "${BRANCH == \'main\' ? \'3000\' : \'3001\'}"'
    PORT_CONT = '"3000"'
  }
}
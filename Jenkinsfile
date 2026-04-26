@Library('jenkins-test-lib') _

pipeline {
  agent any

  tools {
    nodejs 'node'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    DOCKERHUB_REPO = 'engapantio/cicd-with-jenkins'
    DOCKER_CREDS   = 'docker-pat'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build') {
      steps {
        script {
          npm install
        }
      }
    }

    stage('Test') {
      steps {
        script {
          npm test
        }
      }
    }  

    stage('Set Image Tag') {
      steps {
        script {
          env.IMAGE_TAG = getImageTag(env.BRANCH_NAME)
          env.CONTAINER_NAME = getContainerName(env.BRANCH_NAME)
          echo "Branch: ${env.BRANCH_NAME}"
          echo "Image tag: ${env.IMAGE_TAG}"
          echo "Container: ${env.CONTAINER_NAME}"
        }
      }
    }

    stage('Hadolint') {
      agent {
        docker {
          image 'hadolint/hadolint:latest-debian'
          reuseNode true
        }
      }
      steps {
        lintDockerfile()
      }
    }

    stage('Build Image') {
     steps {
        buildDockerImage(env.DOCKERHUB_REPO, env.IMAGE_TAG)
      }
    }

    stage('Trivy Scan') {
      agent {
        docker {
          image 'aquasec/trivy:0.69.3'
          args "--entrypoint='' -v /var/run/docker.sock:/var/run/docker.sock -u 0"
          reuseNode true
        }
      }
      steps {
        scanDockerImage(env.DOCKERHUB_REPO, env.IMAGE_TAG)
      }
    }

    stage('Push Image') {
      steps {
        pushDockerImage(env.DOCKERHUB_REPO, env.IMAGE_TAG, env.DOCKER_CREDS)
      }
    }

    stage('Trigger Deploy') {
      steps {
        script {
          if (env.BRANCH_NAME == 'dev') {
            build job: 'Deploy_to_dev',
              wait: false,
              parameters: [
                string(name: 'DOCKERHUB_REPO', value: env.DOCKERHUB_REPO),
                string(name: 'IMAGE_TAG', value: env.IMAGE_TAG)
              ]
          }

          if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
            build job: 'Deploy_to_main',
              wait: false,
              parameters: [
                string(name: 'DOCKERHUB_REPO', value: env.DOCKERHUB_REPO),
                string(name: 'IMAGE_TAG', value: env.IMAGE_TAG)
              ]
          }
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline finished'
    }
    success {
      echo 'Pipeline succeeded'
    }
    failure {
      echo 'Pipeline failed'
    }
  }
}

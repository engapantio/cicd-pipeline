pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    environment {
        BRANCH = "${env.BRANCH_NAME}"
        IMAGE_NAME = "${BRANCH == 'main' ? 'nodemain' : 'nodedev'}"
        PORT_HOST = "${BRANCH == 'main' ? '3000' : '3001'}"
        PORT_CONT = "3000"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:v1.0 ."
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true
                    docker run -d --name ${IMAGE_NAME} \
                        --expose ${PORT_HOST} \
                        -p ${PORT_HOST}:${PORT_CONT} \
                        ${IMAGE_NAME}:v1.0
                """
            }
        }
    }

    post {
        success {
            echo "Deployed ${BRANCH} to http://localhost:${PORT_HOST}"
        }
        failure {
            echo "Pipeline failed for branch: ${BRANCH}"
        }
    }
}
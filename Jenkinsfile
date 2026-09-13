pipeline {
    agent {
        dockerfile {
            filename 'ci-agent.Dockerfile'
            args '--user=node --network=host -v /certs/client:/certs/client:ro'
            reuseNode true
        }
    }

    environment {
        IMAGE_NAME = 'isec6000-app'
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_CERT_PATH = '/certs/client'
        DOCKER_TLS_VERIFY = '1'
    }

    options {
        timestamps()
    }

    stages {
        stage('Install dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Unit tests') {
            steps {
                sh 'npm test -- --json --outputFile=test-results.json'
            }
        }

        stage('Dependency security scan') {
            steps {
                sh 'npm audit --audit-level=high --json > audit-report.json'
            }
        }

        stage('Build Docker image') {
            steps {
                sh '''
                    IMAGE_TAG="build-${BUILD_NUMBER}"

                    DOCKER_HOST="tcp://localhost:2376" \
                    DOCKER_CERT_PATH="/certs/client" \
                    DOCKER_TLS_VERIFY="1" \
                    docker build \
                      --tag "${IMAGE_NAME}:${IMAGE_TAG}" .

                    DOCKER_HOST="tcp://localhost:2376" \
                    DOCKER_CERT_PATH="/certs/client" \
                    DOCKER_TLS_VERIFY="1" \
                    docker image inspect \
                      "${IMAGE_NAME}:${IMAGE_TAG}" > image-metadata.json
                '''
            }
        }

        stage('Push Docker image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKERHUB_USERNAME',
                    passwordVariable: 'DOCKERHUB_TOKEN'
                )]) {
                    sh '''
                        set -eu

                        IMAGE_TAG="build-${BUILD_NUMBER}"
                        REMOTE_IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

                        DOCKER_HOST="tcp://localhost:2376" \
                        DOCKER_CERT_PATH="/certs/client" \
                        DOCKER_TLS_VERIFY="1" \
                        docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REMOTE_IMAGE}"

                        printf '%s' "${DOCKERHUB_TOKEN}" | \
                        DOCKER_HOST="tcp://localhost:2376" \
                        DOCKER_CERT_PATH="/certs/client" \
                        DOCKER_TLS_VERIFY="1" \
                        docker login \
                          --username "${DOCKERHUB_USERNAME}" \
                          --password-stdin

                        DOCKER_HOST="tcp://localhost:2376" \
                        DOCKER_CERT_PATH="/certs/client" \
                        DOCKER_TLS_VERIFY="1" \
                        docker push "${REMOTE_IMAGE}"

                        DOCKER_HOST="tcp://localhost:2376" \
                        DOCKER_CERT_PATH="/certs/client" \
                        DOCKER_TLS_VERIFY="1" \
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'audit-report.json,image-metadata.json,test-results.json',
                allowEmptyArchive: true
        }
    }
}

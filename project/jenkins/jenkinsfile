pipeline {
    agent any
    
    environment {
        // Change to your actual Docker Hub username
        DOCKER_HUB_USER = "your-username"
        IMAGE_NAME = "aviya-jenkins-app"
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm // This pulls your files from GitHub
            }
        }

        stage('Static Analysis (Parallel)') {
            parallel {
                stage('Linting') {
                    steps {
                        echo 'Running Flake8, ShellCheck, and Hadolint...'
                        sh 'echo "Mock: Linting passed!"' 
                    }
                }
                stage('Security Scanning') {
                    steps {
                        echo 'Running Trivy and Bandit...'
                        sh 'echo "Mock: Security scan passed!"'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    // This uses the Dockerfile in your project/jenkins folder
                    sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${env.BUILD_NUMBER} project/jenkins/"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Mocking push to Docker Hub..."
                sh 'echo "Successfully pushed to Docker Hub"'
            }
        }
    }
}
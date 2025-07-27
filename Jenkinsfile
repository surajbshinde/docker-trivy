pipeline {
    agent any

    environment {
        IMAGE_NAME = 'my-app:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from GitHub
                git branch: 'main',
                    url: 'https://github.com/surajbshinde/docker-trivy.git'
                    // credentialsId: "${GIT_CREDENTIALS}" // Uncomment if private repo
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "🔧 Building Docker image: ${IMAGE_NAME}"
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Scan Docker Image with Trivy') {
            steps {
                script {
                    echo "🔍 Scanning Docker image with Trivy: ${IMAGE_NAME}"
                    sh '''
                        trivy clean --scan-cache
                        trivy image --severity HIGH,CRITICAL --exit-code 1 --no-progress ${IMAGE_NAME} > trivy-report.txt || true
                        
                        if [ -s trivy-report.txt ]; then
                            echo "Trivy scan found vulnerabilities:"
                            cat trivy-report.txt
                        else
                            echo "✅ No HIGH or CRITICAL vulnerabilities found in the Docker image."
                        fi
                    '''
                }
            }
        }

        stage('Fail Build on Vulnerabilities') {
            steps {
                echo '🔎 Checking Trivy scan result...'
                script {
                    def scanResult = sh(script: 'grep -E "Total: [1-9]" trivy-report.txt || true', returnStatus: true)
                    if (scanResult == 0) {
                        error("❌ Critical or High vulnerabilities found. Failing the build.")
                    } else {
                        echo '✅ No critical/high vulnerabilities found.'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "🧪 Running tests on Docker image: ${IMAGE_NAME}"
                    // You can replace this with your actual test command
                    sh "docker run --rm ${IMAGE_NAME} ./run-tests.sh || true"
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.txt', onlyIfSuccessful: false
        }
        failure {
            echo '❗ Build failed due to vulnerability scan.'
        }
    }
}

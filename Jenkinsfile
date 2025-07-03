pipeline {
    agent any

    environment {
        K8S_MASTER = "ceph1@192.168.13.11"
        DEPLOY_YAML = "k8s-gateway-deployment.yaml"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'gateway', url: 'https://github.com/Maram-web/gateway.git'
            }
        }

        stage('Tag & Build Image') {
            steps {
                script {
                    def tag = "v${new Date().format('yyyyMMdd-HHmmss')}"
                    env.IMAGE_NAME = "marammanai/gateway-service:${tag}"
                    env.IMAGE_TAG = tag
                }
                sh '''
                    echo "🛠️ Docker Build de l'image $IMAGE_NAME"
                    docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME
                    '''
                }
            }
        }

        stage('Copy YAML to Master') {
            steps {
                sh '''
                    echo "📁 Mise à jour de l'image dans le YAML"
                    sed -i "s|image: marammanai/gateway-service:.*|image: marammanai/gateway-service:${IMAGE_TAG}|" $DEPLOY_YAML

                    ssh-keyscan -H 192.168.13.11 >> ~/.ssh/known_hosts
                    scp $DEPLOY_YAML $K8S_MASTER:/home/ceph1/$DEPLOY_YAML
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "🚀 Déploiement Kubernetes"
                    ssh $K8S_MASTER kubectl apply -f /home/ceph1/$DEPLOY_YAML
                '''
            }
        }
    }

    post {
        success {
            echo "✅ gateway-service déployé avec succès avec image taguée : ${IMAGE_TAG}"
        }
        failure {
            echo "❌ Le déploiement de gateway-service a échoué."
        }
    }
}

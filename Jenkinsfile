pipeline {
    agent any

    parameters {
        string(name: 'DOCKERTAG', defaultValue: '', description: 'Docker Tag')
        booleanParam(name: 'BUILD_BACKEND', defaultValue: false, description: 'Indicates if the backend was built')
        booleanParam(name: 'BUILD_FRONTEND', defaultValue: false, description: 'Indicates if the frontend was built')
    }

    stages {
        stage('Debug Parameters') {
            steps {
                script {
                    echo "DOCKERTAG: ${params.DOCKERTAG}"
                    echo "BUILD_BACKEND: ${params.BUILD_BACKEND}"
                    echo "BUILD_FRONTEND: ${params.BUILD_FRONTEND}"

                    if (params.BUILD_BACKEND) {
                        echo "The backend directory was changed."
                    }
                    if (params.BUILD_FRONTEND) {
                        echo "The frontend directory was changed."
                    }
                }
            }
        }

        stage('Checkout') {
            steps {
                // git branch: 'main', url: 'https://github.com/Groupe5-Devops/Deployment.git'
                checkout scm
            }
        }

        stage('Update GIT') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                            // Configure Git user
                            sh "git config user.email Rachik1999@gmail.com"
                            sh "git config user.name SkinnySyd"

                            // Update manifest.yaml files based on changed directories
                            if (params.BUILD_FRONTEND) {
                                echo "Updating frontend manifest.yaml"
                                sh "sed -i 's+us-central1-docker.pkg.dev/citric-period-433211-i6/appmanagercr/servermanagerfront:.*+us-central1-docker.pkg.dev/citric-period-433211-i6/appmanagercr/servermanagerfront:${params.DOCKERTAG}+g' frontend/manifest.yaml"
                            }
                            if (params.BUILD_BACKEND) {
                                echo "Updating backend manifest.yaml"
                                sh "sed -i 's+us-central1-docker.pkg.dev/citric-period-433211-i6/appmanagercr/servermanagerback:.*+us-central1-docker.pkg.dev/citric-period-433211-i6/appmanagercr/servermanagerback:${params.DOCKERTAG}+g' backend/manifest.yaml"
                            }

                            // Show updated manifest.yaml content
                            sh "cat frontend/manifest.yaml"
                            sh "cat backend/manifest.yaml"
                            // Commit and push changes to GitHub
                            sh "git add frontend/manifest.yaml backend/manifest.yaml"
                            sh "git commit -m 'Updated Docker image tags in manifest.yaml files by Jenkins Job changemanifest: ${env.BUILD_NUMBER}'"
                            sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Groupe5-Devops/Deployment.git HEAD:main"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

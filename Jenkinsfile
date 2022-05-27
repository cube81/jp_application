pipeline {
    agent {
        label 'docker-slave'
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "auto_maven"
    }
    environment {
        def IMAGE = sh script: 'mvn help:evaluate -Dexpression=project.ArtifactId -q -DforceStdout', returnStdout: true
        def VERSION = sh script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true
    }
  
    stages {
        stage('Clear running apps') {
           steps {
               // Clear previous instances of app built
               sh 'docker rm -f jpapp || true'
           }
        }
        stage('Get Code') {
            steps {
                // Get some code from a GitHub repository
                checkout scm
            }
        }
        stage('Build and Junit') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn clean install"
            }
        }
        stage('Build Docker image'){
            steps {
                sh "mvn package -Pdocker"
            }
        }
        stage('Run Docker app') {
            steps {
                sh "docker run -d -p 0.0.0.0:8080:8080 --name jpapp -t ${IMAGE}:${VERSION}"
            }
        }
        stage('Test Selenium') {
            steps {
                sh "mvn test -Pselenium"
            }
        }
        stage('Deploy jar to artifactory') {
            steps {
                configFileProvider([configFile(fileId: 'af103f09-255e-4cd9-be6c-c5bf6a20a9f5', variable: 'MAVEN_GLOBAL_SETTINGS')]) {
                    sh "mvn -gs $MAVEN_GLOBAL_SETTINGS deploy -Dmaven.test.skip=true -e"
                }
            } 
        }
    }
    post { 
        always { 
            input 'Docker stop jp aap'
            sh 'docker stop jpapp'
            deleteDir()
        }
    }
}
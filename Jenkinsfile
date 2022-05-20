pipeline {
    agent {
        label 'docker-slave'
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "auto_maven"
        terraform 'Terraform'
    }
    environment {
        //IMAGE = readMavenPom().getArtifactId()
        //VERSION = readMavenPom().getVersion()
        def IMAGE = sh script: 'mvn help:evaluate -Dexpression=project.ArtifactId -q -DforceStdout', returnStdout: true
        def VERSION = sh script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true
        ANSIBLE = tool name: 'Ansible', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
    }
  
    stages {
        stage('Clear running app') {
           steps {
               sh 'docker rm -f jpapp || true'
           }
        }
        stage('Get Code') {
            steps {
                // Get some code from a GitHub repository
                checkout scm
            }
        }


        stage('Copy Ansible role') {
               steps {
                   sh 'sleep 10'
                   sh 'cp -r infrastructure/ansible/jp/ /etc/ansible/roles/'
                   sh 'ls /etc/ansible/roles/'
                }
        }
        stage('Run Ansible') {
               steps {
                dir('infrastructure/ansible') {                
                    sh 'chmod 600 ../jp3.pem'
                    sh 'ls -la'
                    sh 'ansible-playbook -i ./inventory playbook.yml -e ansible_python_interpreter=/usr/bin/python3'
                } 
            }
        }

        stage('Removal of the AWS-VPC environment'){
            steps{
                input 'Remove environment'
                dir('infrastructure/terraform'){
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsjp3-akid']]){
                                sh 'terraform destroy -auto-approve -var-file ./jp.tfvars'
                            }
                }
            }
        }

    }
    post {
            success {
                sh 'docker stop jpapp'
                deleteDir()
            }

            failure {
                dir('infrastructure/terraform') { 
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awsjp3-akid']]) {
                        sh 'terraform destroy -auto-approve -var-file ./jp.tfvars'
                    }
                }
                sh 'docker stop jpapp'
                deleteDir()
            }
        }
}
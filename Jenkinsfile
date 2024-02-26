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
        stage('Deploy jar to Artifactory') {
            steps {
                configFileProvider([configFile(fileId: 'af103f09-255e-4cd9-be6c-c5bf6a20a9f5', variable: 'MAVEN_GLOBAL_SETTINGS')]) {
                    sh "mvn -gs $MAVEN_GLOBAL_SETTINGS deploy -Dmaven.test.skip=true -e"
                }
            } 
        }

        stage('Init Terraform') {
            steps {
                dir('infrastructure/terraform') {
                    sh 'terraform init'
                } 
            }
        }


        stage('Terraform build AWS-VPC') {
            steps {
                dir('infrastructure/terraform') {
                    sh 'terraform init'
                    withCredentials([file(credentialsId: 'jp-drmax', variable: 'terraformjp')]) {
                        sh "cp \$terraformjp ../jp-max.pem"
                    }
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'jp-drmax']]){  
                        sh 'terraform apply -var-file ./jp.tfvars -auto-approve'
                    }
                } 
            }
        }
        stage('Copy Ansible role') {
               steps {
                   dir('infrastructure/ansible') {
                       println "=================== AWS EC2 IPs ==================="
                       sh 'cat inventory'
                       println "==================================================="
                   }
                   sh 'mkdir -pv /etc/ansible/roles/'
                   sh 'sleep 30'
                   sh 'cp -r infrastructure/ansible/jp/ /etc/ansible/roles/'
                }
        }
        stage('Execute Ansible role') {
               steps {
                dir('infrastructure/ansible') {                
                    sh 'chmod 600 ../jp3.pem'
                    sh 'ansible-playbook -i ./inventory playbook.yml -e ansible_python_interpreter=/usr/bin/python3'
                    //sh 'ansible-playbook -i ./inventory playbook.yml'
                } 
            }
        }

        stage('Removal of the AWS-VPC environment'){
            steps{
                input 'Remove environment'
                dir('infrastructure/terraform'){
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'jp-drmax']]){
                                sh 'terraform destroy -auto-approve -var-file ./jp.tfvars'
                            }
                }
            }
        }
    }
    post {
            success {
                sh 'docker stop jpapp'
                //deleteDir()
            }

            failure {
                dir('infrastructure/terraform') { 
                    input 'Remove environment'
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'jp-drmax-key']]) {
                        sh 'terraform destroy -auto-approve -var-file ./jp.tfvars'
                    }
                }
                sh 'docker stop jpapp'
                deleteDir()
            }
        }
}
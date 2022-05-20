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
        //ANSIBLE = tool name: 'Ansible', type: 'com.cloudbees.jenkins.plugins.custotmtools.CusomTool'
    }
  
        stage('Get Code') {
            steps {
                // Get some code from a GitHub repository
                checkout scm
            }
        }

        stage('Run terraform') {
            steps {
                dir('infrastructure/terraform') {
                    sh 'terraform init'
                    withCredentials([file(credentialsId: 'awsjp3-pem', variable: 'terraformjp')]) {
                        sh "cp \$terraformjp ../jp3.pem"
                        sh 'terraform apply -var-file ./jp.tfvars -auto-approve'
                    }
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
}
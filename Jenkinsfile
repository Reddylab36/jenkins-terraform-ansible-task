pipeline {
    agent any
    environment {
        AWS_REGION = 'us-west-1'  // Set AWS region
        TF_VAR_aws_access_key = credentials('aws-access-key-id')  // AWS credentials
        TF_VAR_aws_secret_key = credentials('aws-secret-access-key')  // AWS credentials
    }
    stages {
        stage('Checkout') {
            steps {
                sh 'git clone https://github.com/Reddylab36/jenkins-terraform-ansible-task.git' 
            }
        }
        
        stage('Terraform Apply') {
            steps {
                script {
                    dir('/var/lib/jenkins/workspace/Declarative-job') {
                    sh 'pwd'
                    sh 'terraform init'
                    sh 'terraform validate'
                    // sh 'terraform destroy -auto-approve'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
        
        stage('Ansible Deployment') {
            steps {
                script {
                   sleep '360'
                    ansiblePlaybook becomeUser: 'ec2-user', credentialsId: 'amazonlinux', disableHostKeyChecking: true, installation: 'ansible', inventory: '/var/lib/jenkins/workspace/Declarative-job/inventory.yaml', playbook: '/var/lib/jenkins/workspace/Declarative-job/amazon-playbook.yml', vaultTmpPath: ''
                    ansiblePlaybook become: true, credentialsId: 'ubuntuuser', disableHostKeyChecking: true, installation: 'ansible', inventory: '/var/lib/jenkins/workspace/Declarative-job/inventory.yaml', playbook: '/var/lib/jenkins/workspace/Declarative-job/ubuntu-playbook.yml', vaultTmpPath: ''
                }
            }
        }
    }
}

pipeline {
    agent any
    

    stages {
        stage('Checkout') {
            steps {
                deleteDir()
                sh 'echo cloning repo'
                sh 'git clone https://github.com/Reddylab36/jenkins-terraform-ansible-task.git' 
            }
        }
        
        stage('Terraform Apply') {
            steps {
                script {
                    dir('/var/lib/jenkins/workspace/Declarative-job/jenkins-terraform-ansible-task') {
                        // Use withCredentials to securely access AWS credentials
                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                                 credentialsId: 'aws_credentials',
                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    // Set AWS region if needed
                    env.AWS_DEFAULT_REGION = 'us-west-1'
                    // Execute Terraform commands
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
    }
        
        stage('Ansible Deployment') {
            steps {
                script {
                   sleep '30'
                    ansiblePlaybook becomeUser: 'ec2-user', credentialsId: 'amazonlinux', disableHostKeyChecking: true, installation: 'ansible', inventory: '/var/lib/jenkins/workspace/Declarative-job/jenkins-terraform-ansible-task/inventory.yaml', playbook: '/var/lib/jenkins/workspace/Declarative-job/jenkins-terraform-ansible-task/amazon-playbook.yml', vaultTmpPath: ''
                    ansiblePlaybook become: true, credentialsId: 'ubuntuuser', disableHostKeyChecking: true, installation: 'ansible', inventory: '/var/lib/jenkins/workspace/Declarative-job/jenkins-terraform-ansible-task/inventory.yaml', playbook: '/var/lib/jenkins/workspace/Declarative-job/jenkins-terraform-ansible-task/ubuntu-playbook.yml', vaultTmpPath: ''
                }
            }
        }
    }
}

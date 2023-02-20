pipeline {
  agent any
    parameters {
        choice(name: 'validate', choices: ['small', 'medium', 'full'], description: 'Choose the validate level')
        string(name: 'service', defaultValue: 'IMS', description: 'Service')
        choice(name: 'cloud', choices: ['Azure', 'Aws'], description: 'Cloud provider')
        string(name: 'form_factor', defaultValue: 'CNF', description: 'Form factor')
    }
   environment {
        AWS_DEFAULT_REGION = 'ap-northeast-1'
        // AWS_ACCESS_KEY_ID = credentials('  ')
        // AWS_SECRET_ACCESS_KEY = credentials('  ')
        // INSTANCE_TYPE = 't2.small'
        AMI_ID = 'ami-068e3d6bc44010346' // Ubuntu 20.04 LTS
        KEY_PAIR_NAME = 'test'
        SECURITY_GROUP_NAME = 'default'
        DOCKER_IMAGE = 'sreeharsha235/kamailio:v1.0'
        // DOCKER_USERNAME = credentials('docker-username')
        // DOCKER_PASSWORD = credentials('docker-password')
    }
  stages {
    stage('Create Small Instance, Install Docker and AWS CLI, Run Docker Container, and Terminate EC2 Instance') {
       when {
            expression {params.cloud == 'Aws' && (params.validate == 'small' || params.validate == 'full' )}
        }
      steps {
        script {
          def instanceId = sh(script: """
            aws ec2 run-instances \\
              --image-id ${AMI_ID} \\
              --instance-type t2.small \\
              --key-name ${KEY_PAIR_NAME} \\
              --security-groups ${SECURITY_GROUP_NAME} \\
              --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Small-Instance-${BUILD_NUMBER}}]' \\
              --query 'Instances[0].InstanceId' \\
              --output text
          """.trim(), returnStdout: true).trim()
          echo "Created EC2 instance: ${instanceId}"
          sh 'sleep 60'
          // Wait for the instance to be running
          sh "aws ec2 wait instance-running --instance-ids ${instanceId}"

          // Connect to the instance via SSH
          def sshUser = 'ubuntu'
          def publicIp = sh(script: "aws ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
        //   def sshKeyFile = '/var/lib/jenkins/test.pem'
          sh """
            ssh -i ~/test.pem  -o StrictHostKeyChecking=no  ubuntu@${publicIp} '
            git clone https://github.com/sreeharsha-alluri/JenkinsEC2Pipeline.git
            sudo bash JenkinsEC2Pipeline/script1
            sudo docker run -itd -p 5060:5060/udp -p 5060:5060/tcp -p 5061:5061/tcp --name kamailio --network host ${DOCKER_IMAGE}
            sudo bash JenkinsEC2Pipeline/script2
            sudo aws ec2 terminate-instances --instance-ids ${instanceId}
            '
            """
        }
      }
    }
    stage('Create Medium Instance, Install Docker and AWS CLI, Run Docker Container, and Terminate EC2 Instance') {
       when {
            expression {params.cloud == 'Aws' && (params.validate == 'medium' || params.validate == 'full' )}
        }
      steps {
        script {
          def instanceId = sh(script: """
            aws ec2 run-instances \\
              --image-id ${AMI_ID} \\
              --instance-type t2.medium \\
              --key-name ${KEY_PAIR_NAME} \\
              --security-groups ${SECURITY_GROUP_NAME} \\
              --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Medium-Instance-${BUILD_NUMBER}}]' \\
              --query 'Instances[0].InstanceId' \\
              --output text
          """.trim(), returnStdout: true).trim()
          echo "Created EC2 instance: ${instanceId}"
          sh 'sleep 60'
          // Wait for the instance to be running
          sh "aws ec2 wait instance-running --instance-ids ${instanceId}"

          // Connect to the instance via SSH
          def sshUser = 'ubuntu'
          def publicIp = sh(script: "aws ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
        //   def sshKeyFile = '/var/lib/jenkins/test.pem'
          sh """
            ssh -i ~/test.pem  -o StrictHostKeyChecking=no  ubuntu@${publicIp} '
              git clone https://github.com/sreeharsha-alluri/JenkinsEC2Pipeline.git
              sudo bash JenkinsEC2Pipeline/script1
              sudo docker run -itd -p 5060:5060/udp -p 5060:5060/tcp -p 5061:5061/tcp --name kamailio --network host ${DOCKER_IMAGE}
              sudo bash JenkinsEC2Pipeline/script2
              sudo aws ec2 terminate-instances --instance-ids ${instanceId}
            '
            """
        }
      }
    }
  }
}

pipeline {

  agent any

  environment {
    SVC_ACCOUNT_KEY = credentials('terraform-auth')
  }
    stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'mkdir -p creds'
        sh 'echo $SVC_ACCOUNT_KEY | base64 -d > ./creds/serviceaccount.json'
      }
    }


      stage('Set Terraform path') {
        steps {
          script {
          def tfHome = tool name: 'monTerraform'
          env.PATH = "${tfHome}:${env.PATH}"
          }
        sh 'terraform --version'
        }
      }  

  }

}

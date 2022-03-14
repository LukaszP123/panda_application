pipeline {
    environment {
        IMAGE = readMavenPom().getArtifactId()
        //IMAGE = sh script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout', returnStdout: true
        VERSION = readMavenPom().getVersion()
        //VERSION = sh script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true
        DOCKER_NAME = "pandaapp"
    }
    agent {
        label 'Slave'
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "auto_maven"
    }

    stages {
        stage('Clear running apps') {
            steps {
                // Clear old app
                sh "docker rm -f $DOCKER_NAME || true"
            }
        }
        stage('Build') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn clean install"
            }
        }
        stage('Docker') {
            steps {
                // Docker.
                sh "mvn package -Pdocker -Dmaven.test.skip=true"
            }
        }
        stage('Starting application') {
            steps {
                // Docker.
                sh "docker run -d -p 8080:8080 --name $DOCKER_NAME ${IMAGE}:${VERSION}"
            }
        }
        stage('Selenium tests') {
            steps {
                // Selenium tests.
                sh "mvn test -Pselenium"
            }
        }
        stage('Artifactory - app deployment') {
            steps {
                configFileProvider([configFile(fileId: 'fd3891fa-f958-499d-81a4-30e5b647208a', variable: 'MAVEN_GLOBAL_SETTINGS')]) {
                    sh "mvn -gs $MAVEN_GLOBAL_SETTINGS deploy -Dmaven.test.skip=true -e"
                }
                //withMaven(globalMavenSettingsConfig: 'null', jdk: 'null', maven: 'auto_maven', mavenSettingsConfig: 'fd3891fa-f958-499d-81a4-30e5b647208a') {
                //    sh "mvn deploy"
                //}
            }
        }
        stage('Run terraform'){
            steps {
                dir('infrastructure/terraform') {
                    withCredentials([file(credentialsId: '9870e8db-d369-4ca0-8d96-0211d1e47a83', variable: 'terraformpanda')]) { sh "cp \$terraformpanda ../panda.pem" }
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                    sh 'terrafom init && terraform apply -auto-approve -var-file panda.tfvars'
                    }
                }
            }
        }
        stage('Copy Ansible role') {
            steps {
                sh 'sleep 180'
                sh 'cp -r infrastructure/ansible/panda/ /etc/ansible/roles/'
            }
        }
        stage('Run Ansible') {
            steps {
                dir('infrastructure/ansible') {
                    sh 'chmod 600 ../panda.pem'
                    sh 'ansible-playbook -i ./inventory playbook.yml -e ansible_python_interpreter=/usr/bin/python3'
                }
            }
        }
        stage('Remove environment') {
            steps {
                input 'Remove environment'
                dir('infrastructure/terraform') { 
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                        sh 'terraform destroy -auto-approve -var-file panda.tfvars'
                    }
                }
            }
        }
    }
    post('Container stop') {
        success { 
           sh "docker stop $DOCKER_NAME"
                deleteDir()
        }
        failure {
            dir('infrastructure/terraform') { 
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                    sh 'terraform destroy -auto-approve -var-file panda.tfvars'
                }
            }
            sh 'docker stop pandaapp'
            deleteDir()
        }
    }
}
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

    }
    post('Container stop') {
        success { 
           sh "docker stop $DOCKER_NAME"
                deleteDir()
        }
    }
}
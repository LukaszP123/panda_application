pipeline {
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
                sh "docker rm -f pandaapp || true"
            }
        }
        stage('Build') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn -Dmaven.test.failure.ignore=true clean install"
            }
        }
        tage('Docker') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn package -Pdocker"
            }
        }
        stage('Selenium tests') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn test -Pselenium"
            }
            
            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
    }
}
pipeline {
    agent any
    tools {
        maven 'Maven' 
	    jdk 'Jdk'
    }
    stages {
    	stage('SonarQube Analysis'){
            steps {
                withSonarQubeEnv('Sonarqube') {
                    sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml sonar:sonar -Dsonar.sources=src/ -Dsonar.exclusions=**/*java*/** -Dsonar.test.exclusions=**/*java*/**"
                    script {
                    timeout(time: 1, unit: 'HOURS') { 
                        sh "curl -u admin:admin -X GET -H 'Accept: application/json' http://localhost:9000/api/qualitygates/project_status?projectKey=com.mycompany:apiops-anypoint-jenkins-sapi > status.json"
                        def json = readJSON file:'status.json'
                        echo "${json.projectStatus}"
                        if ("${json.projectStatus.status}" != "OK") {
                            	currentBuild.result = 'FAILURE'
                           		error('Pipeline aborted due to quality gate failure.')
                           }
                        }     
                    }
                }
            }
        }
        stage('Build') {
            steps {
            		sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml clean install -DskipTests"
                  }    
        } 
        stage ('Munit Test'){
        	steps {
        		    sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml test"
        	      }    
        }
        stage('Functional Testing'){
        	steps {
        			sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml test -Dtestfile=apiops-anypoint-jenkins-sapi/src/test/javarunner.TestRunner.java"
             	  }
            }
        stage('Generate Reports') {
      		steps {
        		    cucumber(failedFeaturesNumber: -1, failedScenariosNumber: -1, failedStepsNumber: -1, fileIncludePattern: 'cucumber.json', jsonReportDirectory: 'apiops-anypoint-jenkins-sapi/target', pendingStepsNumber: -1, skippedStepsNumber: -1, sortingMethod: 'ALPHABETICAL', undefinedStepsNumber: -1)
                  }
            }
        stage('Archetype'){
        	steps {
                    sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml archetype:create-from-project"
                    sh "mvn -f apiops-anypoint-jenkins-sapi/target/generated-sources/archetype/pom.xml clean install"
                  } 
        	}    
        stage('Deploy to Cloudhub'){
        	steps {
        	    	sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml package deploy -DskipTests -Dusername=sivendu04 -Dpassword=Mulesoft903 -DapplicationName=mule-project-njclabs-poc -Denvironment=Sandbox -DmuleDeploy"
             	  }
            }
        
 
    	stage('Email') {
      		steps {
			script {
          		    readProps= readProperties file: 'apiops-anypoint-jenkins-sapi/email.properties'
          		    echo "${readProps['email.to']}"
        		    emailext(subject: 'Testing Reports for $PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: 'Please find the functional testing reports. In order to check the logs also, please go to url: $BUILD_URL'+readFile("apiops-anypoint-jenkins-sapi/emailTemplate.html"), attachmentsPattern: 'apiops-anypoint-jenkins-sapi/target/cucumber-reports/report.html', from: "${readProps['email.from']}", mimeType: "${readProps['email.mimeType']}", to: "${readProps['email.to']}")
                  }
		}
           }    
    }

    post {
        failure {
	    script {
          		readProps= readProperties file: 'apiops-anypoint-jenkins-sapi/email.properties'
				emailext(subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: 'Please find attached logs.', attachLog: true, from: "${readProps['email.from']}", to: "${readProps['email.to']}")
                    }
            
        }
    }
}

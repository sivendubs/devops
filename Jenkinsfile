pipeline {
    agent any
    tools {
        maven 'Maven' 
	  
	    
    }
   stages {
    	stage('SonarQube Analysis'){
            steps {
                withSonarQubeEnv('Sonarqube') {
                    sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml sonar:sonar -Dsonar.sources=src/ -Dsonar.exclusions=**/*java*/** -Dsonar.test.exclusions=**/*java*/**"
                    script {
			last_started = env.STAGE_NAME
			echo "$last_started"
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
	/*    stage('upload to nexus') {
      steps {
        script {
          echo "hello";
          pom = readMavenPom file: "pom.xml";
          filesbyGlob = findFiles(glob: "target/*.jar");
          echo "${filesbyGlob[0].path}";
          nexusArtifactUploader(artifacts: [[artifactId: pom.artifactId, classifier: '', file: filesbyGlob[0].path, type: 'jar']], credentialsId: 'nexus', groupId: pom.groupId, nexusUrl: 'localhost:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'com.testnjc', version: currentBuild.number.toString())
        }
      }
    }*/
        stage('Build') {
            steps {
            		sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml clean install -DskipTests"
                  }    
        } 
       stage('Build image') {
      steps {
        script {
          dockerImage= docker.build("joji/apiops-anypoint-jenkins-sapi")
        }

        echo 'image built'
      }
    }

    stage('Run container') {
      steps {
        script {
          sh 'docker run -itd -p 8081:8081 --name apiops-anypoint-jenkins-sapi  joji/apiops-anypoint-jenkins-sapi'
        }

        echo 'container running'
      }
    }
        stage ('Munit Test'){
        	steps {
        		    sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml test"
        	      }    
        }
        stage('Functional Testing'){
        	steps {
        			sh "mvn -f cucumber-API-Framework/pom.xml test -Dtestfile=cucumber-API-Framework/src/test/javarunner.TestRunner.java"
             	  }
            }
        stage('Generate Reports') {
      		steps {
        		    cucumber(failedFeaturesNumber: -1, failedScenariosNumber: -1, failedStepsNumber: -1, fileIncludePattern: 'cucumber.json', jsonReportDirectory: 'cucumber-API-Framework/target', pendingStepsNumber: -1, skippedStepsNumber: -1, sortingMethod: 'ALPHABETICAL', undefinedStepsNumber: -1)
                  }
            }
          /*stage('Archetype'){
        	steps {
                    sh "mvn -f cucumber-API-Framework/pom.xml archetype:create-from-project"
                    sh "mvn -f cucumber-API-Framework/target/generated-sources/archetype/pom.xml clean install"
                  } 
        	}    
        stage('Deploy to Cloudhub'){
        	steps {
        	    	sh 'mvn -f apiops-anypoint-jenkins-sapi/pom.xml package deploy -DmuleDeploy -Danypoint.username=joji4 -Danypoint.password=Canadavisa25@ -DapplicationName=apiops-anypoint-jenkins-sapi -Dcloudhub.region=us-east-2'
			
             	  }
            }*/
        
 
    	stage('Email') {
      		steps {
			script {
          		    readProps= readProperties file: 'cucumber-API-Framework/email.properties'
          		    echo "${readProps['email.to']}"
        		    emailext(subject: 'Testing Reports for $PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: 'Please find the functional testing reports. In order to check the logs also, please go to url: $BUILD_URL'+readFile("apiops-anypoint-jenkins-sapi/emailTemplate.html"), attachmentsPattern: 'apiops-anypoint-jenkins-sapi/target/cucumber-reports/report.html', from: "${readProps['email.from']}", mimeType: "${readProps['email.mimeType']}", to: "${readProps['email.to']}")
                  }
		}
           }    
    }

    post {
        failure {
	    script {
          		readProps= readProperties file: 'cucumber-API-Framework/email.properties'
				emailext(subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: 'Build Failed at $last_started Stage.\nPlease find attached logs for more details.', attachLog: true, from: "${readProps['email.from']}", to: "${readProps['email.to']}")
                    }
            
        }
    }
}

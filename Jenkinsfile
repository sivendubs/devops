pipeline {
    agent any
    tools {
        maven 'Maven' 
	jdk 'Jdk'
	  
	    
    }
   stages {
    /*	stage('SonarQube Analysis'){
            steps {
                withSonarQubeEnv('Sonarqube') {
                    sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml sonar:sonar -Dsonar.sources=src/ "
                    script {
			LAST_STARTED = env.STAGE_NAME
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
		    	script {
				LAST_STARTED = env.STAGE_NAME
				//configFileProvider([configFile(fileId: 'ef71d2c9-9592-42c9-8de4-27a5a875801b', variable: 'Mvnsettings')]) {
					sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml clean install -DskipTests"
    
			       }
		    	
			//}
            		
                  }    
        } 
      stage('Build image') {
      steps {
        script {
		sh "ls -la"
		LAST_STARTED = env.STAGE_NAME
		sh "/Applications/Docker.app/Contents/Resources/bin/docker stop apiops-anypoint-jenkins-sapi" 
        	sh "/Applications/Docker.app/Contents/Resources/bin/docker rm apiops-anypoint-jenkins-sapi"
          	//dockerImage= /Applications/Docker.app/Contents/Resources/bin/docker.build("sivendu/apiops-anypoint-jenkins-sapi")
		sh "/Applications/Docker.app/Contents/Resources/bin/docker build -t apiops-anypoint-jenkins-sapi:mule -f Dockerfile ." 
        }

        echo 'image built'
      }
    }

    stage('Run container') {
      steps {   
              script {
		      LAST_STARTED = env.STAGE_NAME
          	sh '/Applications/Docker.app/Contents/Resources/bin/docker run -itd -p 8082:8081 --name apiops-anypoint-jenkins-sapi apiops-anypoint-jenkins-sapi:mule'
		      sh 'sleep 60'
	      }
      }
    }
    stage ('Munit Test'){
        	steps {
			script {
				LAST_STARTED = env.STAGE_NAME
				//configFileProvider([configFile(fileId: 'ef71d2c9-9592-42c9-8de4-27a5a875801b', variable: 'Mvnsettings')]) {
				//	sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml -s $Mvnsettings test"
				sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml -Dhttp.port=8083 test"
					
			      // }
			}
        	 }    
        }
       stage('Functional Testing'){
        	steps {
				script {
				LAST_STARTED = env.STAGE_NAME
			       }
			        
        			sh "mvn -f cucumber-API-Framework/pom test -Dtestfile=cucumber-API-Framework/src/test/javarunner.TestRunner.java"
             	      }
            } 
        stage('Generate Reports') {
      		steps {
			   
			script {
				LAST_STARTED = env.STAGE_NAME
			       }
        		    cucumber(failedFeaturesNumber: -1, failedScenariosNumber: -1, failedStepsNumber: -1, fileIncludePattern: 'cucumber.json', jsonReportDirectory: 'cucumber-API-Framework/target', pendingStepsNumber: -1, skippedStepsNumber: -1, sortingMethod: 'ALPHABETICAL', undefinedStepsNumber: -1)
                      }
            }
          /*stage('Archetype'){
        	steps {
			script {
		    		LAST_STARTED = env.STAGE_NAME
		    		configFileProvider([configFile(fileId: '706c4f0b-71dc-46f3-9542-b959e2d26ce7', variable: 'settings')]){
                    			sh "mvn -f apiops-anypoint-jenkins-sapi/pom.xml -s $settings archetype:create-from-project"
		    			sh "mvn -f apiops-anypoint-jenkins-sapi/target/generated-sources/archeype/pom.xml -s $settings clean deploy -DaltSnapshotDeploymentRepository=snapshots::http://admin:NjcNexus@123@104.248.169.167:8081/repository/maven-snapshots/"
                  			} 
		  		}
        		}   
		}
        stage('Deploy to Cloudhub'){
        	steps {
		        LAST_STARTED = env.STAGE_NAME
        	    	sh 'mvn -f apiops-anypoint-jenkins-sapi/pom.xml package deploy -DmuleDeploy -Danypoint.username=joji4 -Danypoint.password=Canadavisa25@ -DapplicationName=apiops-anypoint-jenkins-sapi -Dcloudhub.region=us-east-2'
			
             	  }
            }
        
 
    	stage('Email') {
      		steps {
			script {
			    emailbody = "Build is Success. Please find the attachment for functional testing reports. In order to check the logs, please go to url: $BUILD_URL"
          		    readProps= readProperties file: 'cucumber-API-Framework/email.properties'
          		    echo "${readProps['email.to']}"
        		    	emailext(subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: "$emailbody", attachmentsPattern: 'cucumber-API-Framework/target/cucumber-reports/report.html', from: "${readProps['email.from']}", to: "${readProps['email.to']}")
                  }
		}
           }   */ 
    }

    post {
        failure {
	    script {	
		    	if ($LAST_STARTED == "Munit Test" || $LAST_STARTED == "Functional Testing" || $LAST_STARTED == "Archetype" || $LAST_STARTED == "Deploy to Cloudhub" ){
				sh "/Applications/Docker.app/Contents/Resources/bin/docker stop apiops-anypoint-jenkins-sapi" 
        		   	sh "/Applications/Docker.app/Contents/Resources/bin/docker rm apiops-anypoint-jenkins-sapi"
			}
		    	emailbody = "Current Build Failed at $LAST_STARTED Stage. Please find the attached logs for more details."
          		readProps= readProperties file: 'cucumber-API-Framework/email.properties'
				emailext(subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: "$emailbody", attachLog: true, from: "${readProps['email.from']}", to: "${readProps['email.to']}")
                    }
            
        }
    }
}

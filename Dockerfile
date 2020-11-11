FROM dhaks/mule4.3.0

COPY /apiops-anypoint-jenkins-sapi/target/*.jar /opt/mule/apps/

EXPOSE 8081

CMD [ "/opt/mule/bin/mule"]

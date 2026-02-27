#Build the Maven project
FROM maven:3.9.6-amazoncorretto-21-al2023 as builder
#FROM maven:3.9.8-sapmachine-21 as builder
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN mvn clean install

#Build the Tomcat container
FROM tomcat:jre21
#set environment variables below and uncomment the line. Or, you can manually set your environment on your server.
#ENV JDBC_URL=jdbc:postgresql://<host>:<port>/<database> JDBC_USERNAME=<username> JDBC_PASSWORD=<password>

# Copies updated server.xml to increase HTTP Header Length allowed
COPY container/etc/tomcat/conf/server.xml $CATALINA_HOME/conf/


# Import certificates from 'container/' mount
ADD container/etc/pki/tls/certs/server.pem /usr/local/share/ca-certificates/server.pem
RUN /opt/java/openjdk/bin/keytool -importcert -noprompt -cacerts -file /usr/local/share/ca-certificates/server.pem -trustcacerts -alias internal-server

EXPOSE 8080

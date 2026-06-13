# Use official Tomcat image with Java 17
FROM tomcat:9.0-jdk17

# Metadata
LABEL maintainer="CloudContainer Technologies Private Limited"
LABEL description="Custom Docker image for Java Application"
LABEL author="Murtuza Ansari"
LABEL email="murtuza2696@gmail.com"

# Environment Variables
ENV APP_TYPE=JAVA
ENV COMPANY_TYPE=IT
ENV COMPANY_EMAIL=murtuza@cloudcontainer.in

# Copy WAR file into Tomcat webapps directory
COPY target/java-application-1.0.war /usr/local/tomcat/webapps/

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

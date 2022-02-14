FROM maven:3-openjdk-11
RUN ["mkdir", "/maven_files"]
COPY pom.xml /maven_files/pom.xml
COPY src/ /maven_files/src/
RUN mvn install -f /maven_files/pom.xml

ENTRYPOINT ["java","-jar","/maven_files/target/panda-0.0.1.jar"]

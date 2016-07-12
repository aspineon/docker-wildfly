FROM ubuntu:16.04

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 10.0.0.Final
ENV WILDFLY_SHA1 c0dd7552c5207b0d116a9c25eb94d10b4f375549
ENV JBOSS_HOME /opt/jboss/wildfly

# Set the JAVA_HOME variable to make it clear where Java is located
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ADD assets /tmp

# Execute system update
# openjdk and wildfly will be installed
RUN apt-get update \
	&& apt-get -y install xmlstarlet bsdtar unzip curl wget openjdk-8-jdk \
	&& cd $HOME \
	&& curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
	&& sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
	&& tar xf wildfly-$WILDFLY_VERSION.tar.gz \
	&& mkdir -p $JBOSS_HOME \
	&& mv $HOME/wildfly-$WILDFLY_VERSION/* $JBOSS_HOME/ \
	&& rm wildfly-$WILDFLY_VERSION.tar.gz \
	&& mkdir -p $JBOSS_HOME/modules/com/oracle/ojdbc7/main/ \
	&& mv /tmp/ojdbc7-12.1.0.1.jar $JBOSS_HOME/modules/com/oracle/ojdbc7/main/ojdbc7.jar \
	&& mv /tmp/module.xml $JBOSS_HOME/modules/com/oracle/ojdbc7/main/ \
	&& mv /tmp/waitfordeployment.sh /opt/jboss/wildfly/bin/ \
	&& chmod 777 /opt/jboss/wildfly/bin/waitfordeployment.sh \
	&& rm -rf /tmp/* \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Expose the ports we're interested in
EXPOSE 80

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]

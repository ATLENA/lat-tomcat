#!/bin/bash

# set
INSTALL_FILE_PATH=$(ls ${OPENLENA_HOME}/*.tar.gz)

# install jdk
if $(cat /etc/*-release | grep -q "Ubuntu"); then
  apt-get update
  apt-get install -y openjdk-8-jdk
  JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
elif `cat /etc/*-release | grep -q "Amazon Linux 2"`; then
  yum update -y
  yum install -y tar procps hostname
  yum install -y java-1.8.0-openjdk-devel.x86_64
  JAVA_HOME=/usr/lib/jvm/java
else
  yum update -y
  yum install -y tar
  yum install -y java-1.8.0-openjdk-devel.x86_64
  JAVA_HOME=/usr/lib/jvm/java
fi

# Extract install file
tar -zxf ${INSTALL_FILE_PATH} -C ${OPENLENA_HOME} --strip-components=1

# Clear install file
rm -rf ${INSTALL_FILE_PATH}

# Install lat tomcat
### create argument text file
INSTALL_ARG_FILE=${OPENLENA_HOME}/arg.txt
echo ${JAVA_HOME} >>${INSTALL_ARG_FILE}    # java home
echo ${SERVER_NAME} >>${INSTALL_ARG_FILE}  # server name
echo ${SERVICE_PORT} >>${INSTALL_ARG_FILE} # service port
echo "root" >>${INSTALL_ARG_FILE}          # run user - use default, don't need to input
echo "" >>${INSTALL_ARG_FILE}              # Install root path - use default, don't need to input
echo "" >>${INSTALL_ARG_FILE}              # AJP address - use default, don't need to input
echo "" >>${INSTALL_ARG_FILE}              # log home - use default, don't need to input
echo "" >>${INSTALL_ARG_FILE}              # JVM route - use default, don't need to input

### install
cat ${INSTALL_ARG_FILE}
/bin/bash ${OPENLENA_HOME}/ctl.sh create tomcat <${INSTALL_ARG_FILE}

chmod -R 775 ${OPENLENA_HOME}

#Change root user enabled.
OPENLENA_SERVER_HOME=${OPENLENA_HOME}/servers/${SERVER_NAME}
echo "Change server.xml,start.sh to run as root user"
sed -i "s/\"root\"/\"anonymous\"/g" ${OPENLENA_SERVER_HOME}/start.sh
sed -i "s/checkedOsUsers=\"root\"/checkedOsUsers=\"\"/g" ${OPENLENA_SERVER_HOME}/conf/server.xml

# create image build info
IMAGE_BUILD_INFO_FILE=${OPENLENA_HOME}/etc/info/image-build.info
echo IMAGE BUILD TIME : $(date) >>${IMAGE_BUILD_INFO_FILE}
echo JAVA_HOME : ${JAVA_HOME} >>${IMAGE_BUILD_INFO_FILE}
echo SERVER_NAME : ${SERVER_NAME} >>${IMAGE_BUILD_INFO_FILE}
echo SERVICE_PORT : ${SERVICE_PORT} >>${IMAGE_BUILD_INFO_FILE}
echo INSTALL_FILE_PATH : ${INSTALL_FILE_PATH} >>${IMAGE_BUILD_INFO_FILE}

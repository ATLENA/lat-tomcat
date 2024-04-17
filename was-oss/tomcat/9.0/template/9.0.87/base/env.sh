#!/bin/sh

## Business System Base Environment (modify them)
export JAVA_HOME=/usr/bin/java
export LAT_HOME=/apps/lat/1.0.0
export INSTANCE_ID=lat
export SERVICE_PORT=7000
export HTTPS_SERVICE_PORT=`expr ${SERVICE_PORT} + 363`
export AJP_PORT=`expr ${SERVICE_PORT} - 71`
export SHUTDOWN_PORT=`expr ${SERVICE_PORT} - 75`
export JVM_MAX_HEAP_SIZE=2048
export JVM_MIN_HEAP_SIZE=2048
export INSTALL_PATH=/apps/lat/1.0.0/instances/lat-was-8080
export RUN_USER=tomcat
export DATE=`date +%Y%m%d-%H%M%S`
export DATE_YMD=`date +%Y%m%d`
export JVM_ROUTE=lat_7000
export SHUTDOWN_TIMEOUT=86400
export SHUTDOWN_ARGUMENTS="${SHUTDOWN_TIMEOUT} -force"

## Catalina Environment (don't modify them)
export PATH="${PATH}":.
export ENGN_VERSION="1.0.0"
export ENGN_HOME="${LAT_HOME}/engines/runtime/tomcat/${ENGN_VERSION}"
export TEMPLATE_VERSION="1.0.0"
export CATALINA_HOME=${ENGN_HOME}

export CATALINA_BASE=${INSTALL_PATH}

export INST_NAME=${INSTANCE_ID}_`hostname`
export LOG_HOME=${INSTALL_PATH}/logs
export LOG_MAX_DAYS=0
export DUMP_HOME=${LOG_HOME}
export CATALINA_OUT_HOME=${LOG_HOME}
export CATALINA_OUT=${CATALINA_OUT_HOME}/${INST_NAME}_${DATE_YMD}.log

export CATALINA_PID=${CATALINA_BASE}/${INST_NAME}.pid

export AJP_ADDRESS=127.0.0.1
export AJP_SECRET=LAT_AJP_SECRET

## LA:T Server Configuration
export ADVERTISER_LIB_PATH=`ls -t ${CATALINA_HOME}/lib/lena-advertiser-*.jar | head -n1`
export CATALINA_OPTS=" -javaagent:${ADVERTISER_LIB_PATH}"
#export CATALINA_OPTS=" ${CATALINA_OPTS} -javaagent:${INSTALL_PATH}/lib/core-1.1.0.jar"
#export CATALINA_OPTS=" ${CATALINA_OPTS} -Ddolly.properties=${INSTALL_PATH}/conf/dolly.properties"
export CATALINA_OPTS=" ${CATALINA_OPTS} -Dlena.name=${INSTANCE_ID}"
export CATALINA_OPTS=" ${CATALINA_OPTS} -Dlena.config=${INSTALL_PATH}/conf/advertiser.conf"
export CATALINA_OPTS=" ${CATALINA_OPTS} -Dlat.name=${INSTANCE_ID}"


## Server custom settings 
  if [ -r "$CATALINA_BASE/bin/customenv.sh" ]; then
    . "$CATALINA_BASE/bin/customenv.sh"
  fi

export CATALINA_OPTS

## Catalina Java Options (don't modify them)
JAVA_OPTS=" ${JAVA_OPTS} -server"
#JAVA_OPTS=" ${JAVA_OPTS} -d64"
JAVA_OPTS=" ${JAVA_OPTS} -DjvmRoute=${JVM_ROUTE}"
JAVA_OPTS=" ${JAVA_OPTS} -Dwas_cname=${INST_NAME}"
JAVA_OPTS=" ${JAVA_OPTS} -Dport.http=${SERVICE_PORT}"
JAVA_OPTS=" ${JAVA_OPTS} -Dport.https=${HTTPS_SERVICE_PORT}"
JAVA_OPTS=" ${JAVA_OPTS} -Dport.ajp=${AJP_PORT}"
JAVA_OPTS=" ${JAVA_OPTS} -Dport.shutdown=${SHUTDOWN_PORT}"
JAVA_OPTS=" ${JAVA_OPTS} -Dlog.home=${LOG_HOME}"
JAVA_OPTS=" ${JAVA_OPTS} -Dlat.home=${LAT_HOME}"
JAVA_OPTS=" ${JAVA_OPTS} -Dajp.address=${AJP_ADDRESS}"
JAVA_OPTS=" ${JAVA_OPTS} -Dajp.secret=${AJP_SECRET}"
JAVA_OPTS=" ${JAVA_OPTS} -Djdk.attach.allowAttachSelf=true"

export JAVA_OPTS

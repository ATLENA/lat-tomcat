#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`

. ${SCRIPTPATH}/env.sh

${LAT_HOME}/latctl.sh start tomcat ${INSTANCE_ID}


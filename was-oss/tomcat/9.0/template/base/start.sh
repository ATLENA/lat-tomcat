#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`

. ${SCRIPTPATH}/env.sh

${LAT_HOME}/enlena/*RELEASE/bin/latctl.sh start tomcat ${INSTANCE_ID}


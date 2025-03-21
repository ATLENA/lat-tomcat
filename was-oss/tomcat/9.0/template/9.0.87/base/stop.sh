#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`

. ${SCRIPTPATH}/env.sh

${OPENLENA_HOME}/ctl.sh stop tomcat ${INSTANCE_ID}


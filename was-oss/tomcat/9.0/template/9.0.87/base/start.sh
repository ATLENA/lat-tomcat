#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`

. ${SCRIPTPATH}/env.sh

${OPENLENA_HOME}/ctl.sh start tomcat ${INSTANCE_ID}


# Determine Java major version
JAVA_VERSION_FULL=$("${JAVA_HOME}/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION_FULL" | awk -F. '{if ($1 == "1") print $2; else print $1}')

## JVM Memory Options (tune them)
CATALINA_OPTS=" ${CATALINA_OPTS} -Xms${JVM_MIN_HEAP_SIZE}m -Xmx${JVM_MAX_HEAP_SIZE}m"
CATALINA_OPTS=" ${CATALINA_OPTS} -XX:MaxMetaspaceSize=256m"

# JVM GC Options based on Java version
if [ "$JAVA_MAJOR_VERSION" -lt 16 ]; then
  # JDK 8 ~ 15
  CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+UseParallelGC"
  CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+UseParallelOldGC"
  CATALINA_OPTS=" ${CATALINA_OPTS} -XX:-UseAdaptiveSizePolicy"
else
  # Above JDK 16 (UseParallelOldGC removed)
  CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+UseParallelGC"
fi

CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+ExplicitGCInvokesConcurrent"
CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
CATALINA_OPTS=" ${CATALINA_OPTS} -XX:HeapDumpPath=${DUMP_HOME}/hdump"
CATALINA_OPTS=" ${CATALINA_OPTS} -Djava.net.preferIPv4Stack=true"
## JVM Memory Options (for JDK8 or below)
if [ -r "${JAVA_HOME}/lib/tools.jar" ]; then
  CATALINA_OPTS=" ${CATALINA_OPTS} -Xloggc:${LOG_HOME}/gc_${INST_NAME}_${DATE}.log"
  CATALINA_OPTS=" ${CATALINA_OPTS} -verbose:gc"
  CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+PrintGCDetails"
  CATALINA_OPTS=" ${CATALINA_OPTS} -XX:+PrintGCDateStamps"
fi
## JVM Memory Options (for JDK11 or above)
if [ -r "${JAVA_HOME}/lib/jrt-fs.jar" ]; then
  CATALINA_OPTS=" ${CATALINA_OPTS} -Xlog:gc:${LOG_HOME}/gc_${INST_NAME}_${DATE}.log"
fi

## Business System Java Options (for your application)
#CATALINA_OPTS=" ${CATALINA_OPTS} "
## Faster Secure Random
CATALINA_OPTS=" ${CATALINA_OPTS} -Djava.security.egd=file:///dev/urandom"

export CATALINA_OPTS

## Add tools.jar to CLASSPATH
if [ -r ${JAVA_HOME}/lib/tools.jar ]; then
  CLASSPATH="${CLASSPATH}:${JAVA_HOME}/lib/tools.jar"
fi

## Business System CLASSPATH (for your application)
#CLASSPATH="${CLASSPATH}:${CATALINA_BASE}/lib/ojdbc6.jar"
export CLASSPATH

## LIBRARY_PATH
LD_LIBRARY_PATH=${CATALINA_HOME}/lib
export LD_LIBRARY_PATH

## Logging output options ('file' or 'console') 
LOG_OUTPUT=file
export LOG_OUTPUT

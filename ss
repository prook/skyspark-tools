#!/bin/sh

PIDFILE="/tmp/skyspark.pid"
OUTFILE="/tmp/skyspark.out"
SKYSPARK="skyspark"
ACT=$1


get_pid() {
	if [ -f "${PIDFILE}" ]; then
		cat ${PIDFILE}
	fi
}

start() {
	PID=`get_pid`

	if [ -z "${PID}" ]; then
		FAN_ENV="util::PathEnv" ${SKYSPARK} -noAuth >> ${OUTFILE} 2>&1 &
		PID=$!
		echo $PID > $PIDFILE
		echo "Started SkySpark (pid $PID)"
	else
		echo "According to ${PIDFILE}, SkySpark is already running (pid ${PID})"
	fi
}

stop() {
	PID=`get_pid`

	if [ -z "${PID}" ]; then
		echo "According to ${PIDFILE}, SkySpark is not running"
	else
		kill ${PID} \
			&& rm ${PIDFILE} \
			&& echo "SkySpark stopped"
	fi
}

print_status() {
	PID=`get_pid`

	if [ -z "${PID}" ]; then
		echo "SkySpark not running (${PIDFILE} not found or empty)"
	else
		echo "SkySpark running (pid ${PID})"
	fi
}

watch() {
	tail -f ${OUTFILE} -n 1000 --retry
}

usage() {
	cat <<EOF

SkySpark shell launcher.

Usage: `basename $0` <command>

Commands:

  start          Start SkySpark (unless already running)
  stop           Stop SkySpark (if running)
  status         Print SkySpark status
  restart        Restart SkySpark
  watch          Watch SkySpark's log

EOF
}

which ${SKYSPARK} >> /dev/null

if [ $? -ne 0 ]; then
	echo "Command '${SKYSPARK}' not found. Make sure SKYSPARK_HOME/bin is on PATH."
	exit 1
fi

case "${ACT}" in
	s|start) start;;
	e|stop) stop;;
	t|status) print_status;;
	r|restart) stop; start;;
	w|watch) watch;;
	*) usage;;
esac

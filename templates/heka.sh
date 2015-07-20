#!/bin/sh
#
# hekad <summary>
#
# chkconfig:   2345 80 20
# description: Starts and stops a single heka instance on this system 
#

### BEGIN INIT INFO
# Provides: Heka
# Required-Start: $network $named
# Required-Stop: $network $named
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: This service manages the hekad daemon
# Description: Heka is a high performance general purpose data acquisition and processing engine.
### END INIT INFO

#
# init.d / servicectl compatibility (openSUSE)
#
if [ -f /etc/rc.status ]; then
    . /etc/rc.status
    rc_reset
fi

#
# Source function library.
#
if [ -f /etc/rc.d/init.d/functions ]; then
    . /etc/rc.d/init.d/functions
fi

exec="/usr/bin/hekad"
prog="hekad"
pidfile=/var/run/${prog}.pid

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/$prog

HEKA_USER=root

start() {
    [ -x $exec ] || exit 5
    [ -f $CONF_FILE ] || exit 6
    echo -n $"Starting $prog: "
    if [ -f $pidfile ] && kill -0 $(cat $pidfile) 2> /dev/null; then
		echo "$0 already running"
		exit 0
	fi
    # if not running, start it up here, usually something like "daemon $exec"
    $exec -config=/etc/heka/ &> /var/log/hekad.log &
    # save pid to file
    echo $! > $pidfile
    sleep 3
    kill -0 $(cat $pidfile) >/dev/null 2>&1
    retval=$?
    [ $retval -eq 0 ] && success || failure
    echo
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    # stop it here, often "killproc $prog"
    killproc -p $pidfile $prog
    #/usr/local/bin/daemon -nhekad --stop
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    restart
}

force_reload() {
    restart
}

rh_status() {
    # run checks to determine if the service is running or use generic status
    status -p $pidfile $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}


case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?
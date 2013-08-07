class jyu_kopla_supervisor {
  exec { "supervisor":
    command => "pip install supervisor==3.0b2",
    onlyif => "test `pip list | grep -c supervisor` -eq 0",
    path => ["/bin", "/usr/bin"],
    require => Class["jyu_kopla_pip"],
  }

  file { "/etc/supervisord.conf":
    content => '[supervisord]
childlogdir = /var/log/supervisor
logfile = /var/log/supervisor/supervisord.log
logfile_maxbytes = 50MB
logfile_backups = 10
loglevel = info
pidfile = /var/run/supervisord.pid
umask = 022
user = root
nodaemon = false
nocleanup = false
environment = LANG=en_US.UTF-8

[include]
files = /etc/supervisord.d/*.conf

[inet_http_server]
port = 19001
username = vagrant
password = vagrant

[supervisorctl]
serverurl = http://localhost:19001
username = vagrant
password = vagrant

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface
'
  }

  file { "/etc/supervisord.d":
    ensure => "directory"
  }

  file { "/var/log/supervisor":
    ensure => "directory"
  }

  file { "/etc/init.d/supervisor":
    ensure => 'present',
    mode => 0744,
    content => '#!/bin/sh
#
# /etc/init.d/supervisor
#
# Supervisor is a client/server system that
# allows its users to monitor and control a
# number of processes on UNIX-like operating
# systems.
#
# chkconfig: - 64 36
# description: Supervisor Server
# processname: supervisord

# Source init functions
. /etc/rc.d/init.d/functions

prog="supervisord"

prefix="/usr"
exec_prefix="${prefix}"
prog_bin="${exec_prefix}/bin/supervisord"
PIDFILE="/var/run/$prog.pid"

start()
{
    echo -n $"Starting $prog: "
    daemon $prog_bin -c /etc/supervisord.conf --pidfile $PIDFILE
    [ -f $PIDFILE ] && success $"$prog startup" || failure $"$prog startup"
    echo
}

stop()
{
    echo -n $"Shutting down $prog: "
    [ -f $PIDFILE ] && killproc $prog || success $"$prog shutdown"
    echo
}

case "$1" in
    start)
        start
    ;;

    stop)
        stop
    ;;

    status)
        status $prog
    ;;

    restart)
        stop
        start
    ;;

    *)
        echo "Usage: $0 {start|stop|restart|status}"
    ;;
esac
',
    require => Exec["supervisor"],
  }

  exec {"chkconfig --add supervisor":
    onlyif => "test `chkconfig --list | grep -c supervisor` -eq 0",
    path => ["/bin", "/usr/bin", "/sbin"],
    require => [
      File["/etc/init.d/supervisor"],
      File["/etc/supervisord.conf"],
      File["/etc/supervisord.d"],
      File["/var/log/supervisor"]
    ]
  }

  exec {"chkconfig supervisor on":
    onlyif => "test `chkconfig --list supervisor | grep -c on` -eq 0",
    path => ["/bin", "/usr/bin", "/sbin"],
    require => Exec["chkconfig --add supervisor"],
  }

  exec {"service supervisor restart":
    path => ["/usr/bin", "/sbin"],
    subscribe => Exec["chkconfig supervisor on"],
    refreshonly => true
  }
}

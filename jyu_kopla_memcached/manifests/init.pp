class jyu_kopla_memcached {
  package { "memcached":
    ensure => "present",
    require => Class["epel"],
  }

  exec { "chkconfig memcached on":
    onlyif => "test `chkconfig --list memcached | grep -c on` -eq 0",
    path => ["/bin", "/sbin", "/usr/bin"],
    require => Package["memcached"],
  }

  exec { "service memcached start":
    onlyif => "test `service memcached status | grep -c stopped` -eq 1",
    path => ["/bin", "/sbin", "/usr/bin"],
    require => Package["memcached"],
  }
}

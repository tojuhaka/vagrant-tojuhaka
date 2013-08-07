class jyu_kopla_buildout (
  $extensions = "buildout.sendpickedversions==1.0-alpha.1",
  $send_data_url = "https://jyuplone.cc.jyu.fi/whiskers"
){

  user { "buildout":
    ensure => "present",
    home => "/home/buildout"
  }

  file { "/home/buildout":
    ensure => "directory",
    owner => "buildout",
    require => User["buildout"],
  }

  file { "/var/buildout":
    ensure => "directory",
    mode => 0744,
    owner => "buildout",
    require => User["buildout"],
  }

  file { "/var/buildout/eggs-directory":
    ensure => "directory",
    mode => 0744,
    owner => "buildout",
    require => File["/var/buildout"],
  }

  file { "/var/buildout/download-cache":
    ensure => "directory",
    mode => 0744,
    owner => "buildout",
    require => File["/var/buildout"],
  }

  file { "/var/buildout/extends-cache":
    ensure => "directory",
    mode => 0744,
    owner => "buildout",
    require => File["/var/buildout"],
  }

  file { "/home/buildout/.buildout":
    ensure => "directory",
    owner => "buildout",
    group => "root",
    require => File["/home/buildout"],
  }

  file { "/home/buildout/.buildout/default.cfg":
    ensure => "present",
    content => "[buildout]
eggs-directory = /var/buildout/eggs-directory
download-cache = /var/buildout/download-cache
extends-cache = /var/buildout/extends-cache
extensions = ${extensions}
send-data-url = ${send_data_url}
",
    owner => "buildout",
    require => [
      File["/home/buildout/.buildout"],
      File["/var/buildout/eggs-directory"],
      File["/var/buildout/download-cache"],
      File["/var/buildout/extends-cache"]
    ]
  }

  file { "/root/.buildout":
    ensure => "directory"
  }

  file { "/root/.buildout/eggs-directory":
    ensure => "directory",
    require => File["/root/.buildout"],
  }

  file { "/root/.buildout/download-cache":
    ensure => "directory",
    require => File["/root/.buildout"],
  }

  file { "/root/.buildout/extends-cache":
    ensure => "directory",
    require => File["/root/.buildout"],
  }

  file { "/root/.buildout/default.cfg":
    ensure => "present",
    content => '[buildout]
eggs-directory = /root/.buildout/eggs-directory
download-cache = /root/.buildout/download-cache
extends-cache = /root/.buildout/extends-cache
',
    require => [
      File["/root/.buildout"],
      File["/root/.buildout/eggs-directory"],
      File["/root/.buildout/download-cache"],
      File["/root/.buildout/extends-cache"]
    ]
  }
}

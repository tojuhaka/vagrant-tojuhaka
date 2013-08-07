class jyu_kopla_metronome (
  $pika_metronome = "https://jyuplone.cc.jyu.fi/packages/pika-metronome-1.3.2.zip"
){
  rabbitmq_user { "metronome":
    admin    => false,
    password => "metronome",
    provider => "rabbitmqctl",
    require => Class["jyu_kopla_rabbitmq"],
  }

  # XXX: read == write and write == read in the current version
  rabbitmq_user_permissions { "metronome@/":
    configure_permission => "^metronome",
    read_permission      => "^metronome",
    write_permission     => "^metronome",
    provider => "rabbitmqctl",
    require => Rabbitmq_user["metronome"],
  }

  file { "/var/buildout/metronome":
    ensure => "directory",
    owner => "buildout",
    require => Class["jyu_kopla_buildout"],
  }

  exec { "/var/buildout/metronome/bootstrap.py":
    command => "curl -O http://downloads.buildout.org/2/bootstrap.py",
    creates => "/var/buildout/metronome/bin/buildout",
    user => "buildout",
    cwd => "/var/buildout/metronome",
    path => ["/bin", "/usr/bin"],
    require => File["/var/buildout/metronome"],
  }

  file { "/var/buildout/metronome/buildout.cfg":
    ensure => "present",
    content => "[buildout]
find-links = ${pika_metronome}
parts = metronome
versions = versions

[versions]
pika = 0.9.8

[metronome]
<= config
recipe = zc.recipe.egg
eggs = pika-metronome
scripts = metronome
arguments = \"\${:host}\",\${:port},\"\${:vhost}\",\"\${:user}\",\"\${:pass}\"

[config]
host = localhost
port = 5672
vhost = /
user = metronome
pass = metronome
",
    owner => "buildout",
    require => File["/var/buildout/metronome"],
  }

  jyu_kopla_virtualenvs::virtualenv { "/usr/local/virtualenvs/metronome":
    virtualenv => "/usr/bin/virtualenv",
    packages => [],
    require => Class["jyu_kopla_virtualenvs"],
  }

  exec { "/usr/local/virtualenvs/metronome/bin/python /var/buildout/metronome/bootstrap.py":
    creates => "/var/buildout/metronome/bin/buildout",
    user => "buildout",
    cwd => "/var/buildout/metronome",
    path => ["/usr/bin"],
    require => [
      File["/var/buildout/metronome/buildout.cfg"],
      Jyu_kopla_virtualenvs::Virtualenv["/usr/local/virtualenvs/metronome"]
    ]
  }

  exec { "/var/buildout/metronome/bin/buildout":
    creates => "/var/buildout/metronome/bin/metronome",
    user => "buildout",
    cwd => "/var/buildout/metronome",
    path => ["/bin", "/usr/bin", "/var/buildout/metronome"],
    require => Exec["/usr/local/virtualenvs/metronome/bin/python /var/buildout/metronome/bootstrap.py"],
    subscribe => File["/var/buildout/metronome/buildout.cfg"],
  }

  user { "metronome":
    ensure => "present"
  }

  file { "/etc/supervisord.d/metronome.conf":
    ensure => present,
    content => '[program:metronome]
command=/var/buildout/metronome/bin/metronome
priority=10
rutostart=true
autorestart=true
user=metronome
',
    require => [
      Exec["/var/buildout/metronome/bin/buildout"],
      Rabbitmq_user["metronome"],
      Rabbitmq_user_permissions["metronome@/"],
      User["metronome"]
    ]
  }

  exec { "sudo supervisorctl reload":
    path => ["/usr/bin"],
    require => File["/etc/supervisord.d/metronome.conf"],
    subscribe => Exec["/var/buildout/metronome/bin/buildout"],
    refreshonly => true,
  }
}

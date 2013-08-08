class disable_sendmail {
  file { "/etc/hosts":
    ensure => "present",
    content => "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.0.1   smtp.jyu.fi
"
  }
  exec {"chkconfig postfix off":
    onlyif => "test `chkconfig --list postfix | grep -c on` -eq 1",
    path => ["/bin", "/usr/bin", "/sbin"],
  }
  exec {"service postfix stop":
    path => ["/usr/bin", "/sbin"],
    subscribe => Exec["chkconfig postfix off"],
    refreshonly => true
  }
}
class { "disable_sendmail": }

file { "/home/vagrant/.buildout":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant"
}

file { "/var/buildout":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant"
}

file { "/var/buildout/eggs-directory":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant",
  require => File["/var/buildout"]
}

exec { "chown -R vagrant /var/buildout/eggs-directory":
  require => File["/var/buildout/eggs-directory"],
  path => ["/bin"]
}

file { "/var/buildout/download-cache":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant",
  require => File["/var/buildout"]
}

exec { "chown -R vagrant /var/buildout/download-cache":
  require => File["/var/buildout/download-cache"],
  path => ["/bin"]
}

file { "/var/buildout/extends-cache":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant",
  require => File["/var/buildout"]
}

exec { "chown -R vagrant /var/buildout/extends-cache":
  require => File["/var/buildout/extends-cache"],
  path => ["/bin"]
}

exec { "download mercurial_keyring.py":
  user => "vagrant",
  cwd => "/home/vagrant",
  command => "wget http://bitbucket.org/Mekk/mercurial_keyring/raw/default/mercurial_keyring.py",
  path => ["/bin", "/usr/bin", "/usr/local/bin"]
}


file { "/home/vagrant/.buildout/default.cfg":
  ensure => "present",
  content => '[buildout]
eggs-directory = /var/buildout/eggs-directory
download-cache = /var/buildout/download-cache
extends-cache = /var/buildout/extends-cache
',
  owner => "vagrant",
  group => "vagrant",
  require => [
    File["/var/buildout/eggs-directory"],
    File["/var/buildout/download-cache"],
    File["/var/buildout/extends-cache"]
  ]
}

file { "/home/vagrant/.pycharm_helpers":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant"
}

file { "/home/vagrant/.pdbrc":
  ensure => 'present',
  content => '# Enable tab completion
import rlcompleter
import pdb
pdb.Pdb.complete = rlcompleter.Completer(locals()).complete

# Sometimes when you do something funky, you may lose your terminal echo. This
# should restore it when spanwning new pdb.
import termios, sys
termios_fd = sys.stdin.fileno()
termios_echo = termios.tcgetattr(termios_fd)
termios_echo[3] = termios_echo[3] | termios.ECHO
termios_result = termios.tcsetattr(termios_fd, termios.TCSADRAIN, termios_echo)
',
  owner => "vagrant",
  group => "vagrant"
}

exec { "pip install keyring":
  onlyif => "test `pip list | grep -c keyring` -eq 0",
  path => ["/bin", "/usr/bin"]
}

exec { "pip install mercurial_keyring":
  onlyif => "test `pip list | grep -c mercurial-keyring` -eq 0",
  path => ["/bin", "/usr/bin"],
  require => Exec["pip install keyring"]
}

file { "/home/vagrant/.hgrc":
  ensure => "present",
  content => "[extensions]
bookmarks =
mercurial_keyring = /home/vagrant/mercurial_keyring.py

[auth]
acme.prefix = jyuplone.cc.jyu.fi/code
acme.username = ${rhodecode_username}
acme.schemes = http https

[ui]
username = ${rhodecode_uiname}
verbose = True
merge = vimdiff

[web]
cacerts = /etc/pki/tls/certs/ca-bundle.crt

[merge-tools]
vimdiff.executable = vim
vimdiff.args = -d $base $local $output $other +close +close

[alias]
slog = log -l5 --template '{rev}:{node|short} {desc|firstline}\\n'
",
  owner => "vagrant",
  group => "vagrant",
  require => Exec["pip install mercurial_keyring"]
}



if $configure_verkkomaksut {
  rabbitmq_user { "verkkomaksut":
    admin    => true,
    password => "markkuveksut",
    provider => "rabbitmqctl",
  }

  rabbitmq_vhost { "/verkkomaksut":
    ensure => "present",
    provider => "rabbitmqctl",
  }

  exec { "rabbitmqctl -p /verkkomaksut trace_on":
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    require => Rabbitmq_vhost["/verkkomaksut"],
  }

  rabbitmq_vhost { "/korppi-payments":
    ensure => "present",
    provider => "rabbitmqctl",
  }

  exec { "rabbitmqctl -p /korppi-payments trace_on":
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    require => Rabbitmq_vhost["/korppi-payments"],
  }

  # XXX: read == write and write == read in the current version
  rabbitmq_user_permissions { "verkkomaksut@/verkkomaksut":
    configure_permission => ".*",
    read_permission      => ".*",
    write_permission     => ".*",
    provider => "rabbitmqctl",
    require => [
      Rabbitmq_vhost["/verkkomaksut"],
      Rabbitmq_user["verkkomaksut"]
    ]
  }

  # XXX: read == write and write == read in the current version
  rabbitmq_user_permissions { "verkkomaksut@/":
    configure_permission => "amq.gen-.*",
    read_permission     => "amq.gen-.*",
    write_permission      => "amq.gen-.*|^metronome",
    provider => "rabbitmqctl",
    require => Rabbitmq_user["verkkomaksut"]
  }

  # XXX: read == write and write == read in the current version
  rabbitmq_user_permissions { "verkkomaksut@/korppi-payments":
    configure_permission => ".*",
    read_permission      => ".*",
    write_permission     => ".*",
    provider => "rabbitmqctl",
    require => [
      Rabbitmq_vhost["/korppi-payments"],
      Rabbitmq_user["verkkomaksut"]
    ]
  }
}

class jyu_kopla_rabbitmq {
  package { "erlang":
    require => Class["epel"],
  }

  class { "rabbitmq::repo::rhel":
    version => "3.1.1",
    relversion => "1",
    require => Package["erlang"],
  }

  class { "rabbitmq::server":
    package_name => "rabbitmq-server-3.1.1-1",
    port => "5672",
    delete_guest_user => true,
    require => Class["rabbitmq::repo::rhel"],
  }

  package { "librabbitmq":
    ensure => "installed",
    require => Class["rabbitmq::server"],
  }

  rabbitmq_plugin {"rabbitmq_management":
    ensure => "present",
    provider => "rabbitmqplugins",
    require => Package["librabbitmq"],
  }

  rabbitmq_plugin {"rabbitmq_web_stomp":
    ensure => "present",
    provider => "rabbitmqplugins",
    require => Package["librabbitmq"],
  }

  rabbitmq_plugin {"rabbitmq_management_visualiser":
    ensure => "present",
    provider => "rabbitmqplugins",
    require => Package["librabbitmq"],
  }

  rabbitmq_plugin {"rabbitmq_amqp1_0":
  ensure => "present",
  provider => "rabbitmqplugins",
  require => Package["librabbitmq"],
  }

  exec { "sudo service rabbitmq-server restart":
    path => ["/bin", "/usr/bin"],
    subscribe => [
      Rabbitmq_plugin["rabbitmq_management"],
      Rabbitmq_plugin["rabbitmq_management_visualiser"],
      Rabbitmq_plugin["rabbitmq_web_stomp"],
      Rabbitmq_plugin["rabbitmq_amqp1_0"]
    ],
    refreshonly => true
  }
}

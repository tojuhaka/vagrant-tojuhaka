class jyu_kopla_virtualenvs {
  file { "/usr/local/virtualenvs":
    ensure => "directory"
  }
  exec { "virtualenv":
    command => "pip install virtualenv",
    onlyif => "test `pip list | grep -c virtualenv` -eq 0",
    path => ["/bin", "/usr/bin"],
    require => Class["jyu_kopla_pip"],
  }
}

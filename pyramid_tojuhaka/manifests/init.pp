class pyramid_tojuhaka (
  $versions = ["pyramid"],
) {
  if "pyramid" in $versions {
    jyu_kopla_virtualenvs::virtualenv { "/usr/local/virtualenvs/pyramid":
      virtualenv => "/usr/local/python/bin/virtualenv-2.7",
      require => Class["jyu_kopla_python"]
    }
  }
  file { "/var/pyramid":
    ensure => "directory",
    owner => "vagrant",
    group => "vagrant"
  }
}

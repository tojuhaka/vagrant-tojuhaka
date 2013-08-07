# For declaring packages, which are required later, but may be too generic to
# be declared within more specific modules.

class jyu_kopla_bootstrap {
  package { "git":
    ensure => "present"
  }

  package { "patch":
    ensure => "present"
  }

  package { "python":
    ensure => "present"
  }

  package { "python-devel":
    ensure => "present"
  }

  package { "openldap-devel":
    ensure => "present"
  }

  package { "libxslt-devel":
    ensure => "present"
  }

  package { "readline-devel":
    ensure => "present"
  }

  package { "zlib-devel":
    ensure => "present"
  }

  package { "libjpeg-turbo-devel":
    ensure => "present"
  }

  package { "openssl-devel":
    ensure => "present"
  }

  package { "openldap-clients":
    ensure => "present"
  }

  package { "lynx":
    ensure => "present"
  }
}

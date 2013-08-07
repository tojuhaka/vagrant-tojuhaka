class jyu_kopla_phantomjs {
  package { "freetype":
    ensure => "present"
  }

  package { "fontconfig":
    ensure => "present"
  }

  exec { "curl -O https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-x86_64.tar.bz2":
    creates => "/usr/local/bin/phantomjs",
    cwd => "/tmp",
    path => ["/bin", "/usr/bin"]
  }

  exec { "tar xvjf phantomjs-1.9.0-linux-x86_64.tar.bz2":
    creates => "/tmp/phantomjs-1.9.0-linux-x86_64",
    cwd => "/tmp",
    path => ["/bin", "/usr/bin"],
    require => Exec["curl -O https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-x86_64.tar.bz2"]
  }

  exec { "cp phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/local/bin":
    creates => "/usr/local/bin/phantomjs",
    cwd => "/tmp",
    path => ["/bin", "/usr/bin"],
    require => [
      Package["freetype"],
      Package["fontconfig"],
      Exec["tar xvjf phantomjs-1.9.0-linux-x86_64.tar.bz2"]
    ]
  }
}

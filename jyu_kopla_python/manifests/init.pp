class jyu_kopla_python ($versions = ["2.6", "2.7"]) {

  if "2.6" in $versions {
    $python26parts = "opt virtualenv python-2.6-build python-2.6-virtualenv"
  }
  if "2.7" in $versions {
    $python27parts = "opt virtualenv python-2.7-build python-2.7-virtualenv"
  }

  exec { "/usr/local/python":
    command => "git clone http://github.com/collective/buildout.python/ python",
    creates => "/usr/local/python",
    cwd => "/usr/local",
    path => ["/usr/bin"],
    require => Package["git"]
  }

  file { "/usr/local/python/buildout.cfg":
    ensure => "present",
    content => "[buildout]
extends =
    src/base.cfg
    src/python26.cfg
    src/python27.cfg

python-buildout-root = \${buildout:directory}/src

parts =
    \${buildout:base-parts}
    \${buildout:python26-parts}
    \${buildout:python27-parts}
",
    require => [
      Exec["/usr/local/python"],
      Package["zlib-devel"],
      Package["readline-devel"],
      Package["openssl-devel"]
    ]
  }

  exec { "/usr/local/python/bin/buildout":
    command => "python bootstrap.py",
    creates => "/usr/local/python/bin/buildout",
    cwd => "/usr/local/python",
    path => ["/usr/bin"],
    require => [
      Package["python"],
      File["/usr/local/python/buildout.cfg"]
    ]
  }

  if "2.6" in $versions {
    exec { "bin/buildout install python-2.6":
      command => "bin/buildout install ${python26parts}",
      creates => "/usr/local/python/bin/virtualenv-2.6",
      cwd => "/usr/local/python",
      path => ["/bin", "/usr/bin", "/usr/local/python"],
      timeout => 3600,
      require => [
        Package["patch"],
        Exec["/usr/local/python/bin/buildout"]
      ]
    }
  }

  if "2.7" in $versions {
    exec { "bin/buildout install python-2.7":
      command => "bin/buildout install ${python27parts}",
      creates => "/usr/local/python/bin/virtualenv-2.7",
      cwd => "/usr/local/python",
      path => ["/bin", "/usr/bin", "/usr/local/python"],
      timeout => 3600,
      require => [
        Package["patch"],
        Exec["/usr/local/python/bin/buildout"]
      ]
    }
  }
}

class jyu_kopla_pip{
  exec { "/tmp/distribute-0.6.45.tar.gz":
    command => "curl -O http://pypi.python.org/packages/source/d/distribute/distribute-0.6.45.tar.gz -L",
    creates => "/tmp/distribute-0.6.45.tar.gz",
    cwd => "/tmp",
    path => ["/usr/bin"]
  }

  exec { "/tmp/distribute-0.6.45":
    command => "tar xzvf distribute-0.6.45.tar.gz",
    creates => "/tmp/distribute-0.6.45",
    cwd => "/tmp",
    path => ["/bin", "/usr/bin"],
    require => [
      Exec["/tmp/distribute-0.6.45.tar.gz"]
    ]
  }

  exec { "distribute":
    command => "python setup.py install",
    creates => "/usr/bin/easy_install",
    cwd => "/tmp/distribute-0.6.45",
    path => ["/usr/bin"],
    require => [
      Exec["/tmp/distribute-0.6.45"],
      Package["python"]
    ]
  }

  exec { "pip":
    command => "easy_install pip",
    creates => "/usr/bin/pip",
    path => ["/usr/bin"],
    require => [
      Exec["distribute"]
    ]
  }

  exec { "/usr/bin/pip install -U distribute":
    onlyif => "test `/usr/bin/pip list | grep -c 'distribute (0.6.45)'` -eq 1",
    path => ["/bin", "/usr/bin"],
    require => [
      Exec["pip"]
    ]
  }
}
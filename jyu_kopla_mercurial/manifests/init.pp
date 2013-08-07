class jyu_kopla_mercurial {
  exec { "mercurial":
    command => "pip install mercurial",
    onlyif => "test `pip list | grep -c mercurial` -eq 0",
    path => ["/bin", "/usr/bin"],
    require => [
      Package["python-devel"],
      Class["jyu_kopla_pip"]
    ]
  }
}

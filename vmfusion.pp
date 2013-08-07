# XXX: Not in use

# VMWare Fusion mounts its shares as !%dir!%something, which causes a lot of
# pain with scripts accessing those shares. We must
# 1) delete symlinks created for those shares
# 2) create directories for new mounts
# 3) mount the shares directly into the created directories

file { "/var/buildout":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant"
}

exec { "unlink /var/buildout/plone":
  command => "sudo rm /var/buildout/plone",
  onlyif => "test -h /var/buildout/plone",
  path => ["/usr/bin", "/bin"],
  require => File["/var/buildout"]
}

exec { "/var/buildout/plone":
  command => "mkdir /var/buildout/plone",
  path => ["/bin"],
  subscribe => Exec["unlink /var/buildout/plone"],
  refreshonly => true
}

exec { "mount /var/buildout/plone":
  command => "sudo mount -t vmhgfs .host:/\\!\\%var\\!\\%buildout\\!\\%plone /var/buildout/plone -o uid=501,gid=501",
  path => ["/usr/bin", "/bin"],
  subscribe => Exec["/var/buildout/plone"],
  refreshonly => true
}

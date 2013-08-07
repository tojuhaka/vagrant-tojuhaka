class jyu_kopla_plone (
  $versions = ["plone41", "plone42", "plone43"],
  $python_ldap = "https://jyuplone.cc.jyu.fi/packages/python-ldap-2.3.12.tar.gz"
){
  user { "zope":
    ensure => "present"
  }

  file { "/usr/local/plone-hotfixes":
    ensure => "directory",
    mode => 0744
  }

  if "plone41" in $versions {
    jyu_kopla_virtualenvs::virtualenv { "/usr/local/virtualenvs/plone41":
      virtualenv => "/usr/local/python/bin/virtualenv-2.6",
      python_ldap => $python_ldap,
      require => Class["jyu_kopla_python"]
    }
    file { "/usr/local/plone-hotfixes/plone4":
      ensure => "directory",
      mode => 0744,
      require => File["/usr/local/plone-hotfixes"]
    }
  }
  if "plone42" in $versions {
    jyu_kopla_virtualenvs::virtualenv { "/usr/local/virtualenvs/plone42":
      virtualenv => "/usr/local/python/bin/virtualenv-2.6",
      python_ldap => $python_ldap,
      require => Class["jyu_kopla_python"]
    }
    file { "/usr/local/plone-hotfixes/plone423":
      ensure => "directory",
      mode => 0744,
      require => File["/usr/local/plone-hotfixes"]
    }
  }
  if "plone43" in $versions {
    jyu_kopla_virtualenvs::virtualenv { "/usr/local/virtualenvs/plone43":
      virtualenv => "/usr/local/python/bin/virtualenv-2.7",
      python_ldap => $python_ldap,
      require => Class["jyu_kopla_python"]
    }
    file { "/usr/local/plone-hotfixes/plone43":
      ensure => "directory",
      mode => 0744,
      require => File["/usr/local/plone-hotfixes"]
    }
  }
}

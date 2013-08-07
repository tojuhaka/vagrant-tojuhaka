class vim_tojuhaka {

  # VIM INSTALLATION
  puppi::netinstall { 'vim':
    owner               => 'vagrant',
    url                 => 'ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2',
    extracted_dir       => 'vim73',
    destination_dir     => '/tmp',
    postextract_command => "/tmp/vim73/configure --with-features=huge --enable-rubyinterp --enable-pythoninterp --prefix='/usr/local' && make && sudo make install",
    require => Package['ruby-devel', 'python-devel']
  }

  package { ["ctags", "ruby-devel"]:
    ensure => "installed",
    require => [
      Class [ "epel" ]
    ]
  }

  file { "/usr/local/vim":
    ensure => File
  }

  exec { "clone vimconfig":
      user => "vagrant",
      cwd => "/home/vagrant",
      command => "/usr/bin/git clone https://github.com/tojuhaka/vimconfig",
      path => ["/bin", "/usr/bin"],
      require => [
        Package["git"],
      ]
    }

  exec { "run vim setup":
      user => "vagrant",
      command => "/home/vagrant/vimconfig/setupvim.sh",
      path => ["/bin", "/usr/bin", "/usr/local/bin"],
      timeout => 1800,
      environment => "HOME=/home/vagrant",
      require => [
        Exec["clone vimconfig"],
        puppi::netinstall["vim"],
        Package["ctags"],
        Package["ruby-devel"],
        Package["python-devel"]
      ]
    }
}

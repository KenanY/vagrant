## Standard PATH with nodejs global bin defaults added
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/', '/usr/local/node/node-default/bin' ] }

## Basics
class basic {
  group { 'puppet' :
    ensure => present,
  }

  exec { 'apt-get update':
    command => 'apt-get update',
  }

  package { [ 'python-software-properties']:
    ensure  => present,
  }
}

## Install and configure nginx vhosts and php mod
class nginx {
  require basic
  package { 'nginx':
    ensure => present,
  }

  service { 'nginx':
    ensure     => running,
    hasrestart => true,
    require    => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/php-fpm':
    owner   => root,
    group   => root,
    mode    => 664,
    source  => '/vagrant/vagrant/puppet/files/vhost',
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  file { '/etc/nginx/sites-enabled/default':
    owner   => root,
    ensure  => link,
    target  => '/etc/nginx/sites-available/php-fpm',
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

}

## Install php54 and fpm, install configs
class php54 {
  require basic
  package { ['php5', 'php5-cli', 'php-apc', 'php5-fpm']:
    ensure => present
  }

  package { 'php5-curl':
    ensure => present,
    require => Package['php5']
  }

  package { 'php5-mysql':
    ensure => present
  }

  package { 'php5-dev':
    ensure => present,
  }

  package { 'php-pear':
    ensure  => present,
    require => Package['php5-dev']
  }

  service { 'php5-fpm':
    ensure  => running,
    require => Package['php5-fpm'],
  }

  file { '/etc/php5/fpm/conf.d/custom.ini':
    owner   => root,
    group   => root,
    mode    => 664,
    source  => '/vagrant/vagrant/puppet/files/custom.ini',
    notify  => Service['php5-fpm'],
    require => Package['php5-fpm'],
  }
  
  file { ["/etc/php5/", "/etc/php5/fpm/","/etc/php5/cli/", "/etc/php5/fpm/pool.d/", "/etc/php5/cli/pool.d/"]:
    ensure => directory,
    owner   => root,
    group   => root,
    mode    => 664,
    before => [File ['/etc/php5/fpm/pool.d/www.conf'], File ['/etc/php5/cli/pool.d/www.conf']]
  }

  file { '/etc/php5/fpm/pool.d/www.conf':
    owner   => root,
    group   => root,
    mode    => 664,
    source  => '/vagrant/vagrant/puppet/files/www.conf',
    notify  => Service['php5-fpm'],
    require => Package['php5-fpm'],
  }

  file { '/etc/php5/cli/conf.d/custom.ini':
    owner   => root,
    group   => root,
    mode    => 664,
    source  => '/vagrant/vagrant/puppet/files/custom.ini',
    notify  => Service['php5-fpm'],
    require => Package['php5-fpm'],
  }

  file { '/etc/php5/cli/pool.d/www.conf':
    owner   => root,
    group   => root,
    mode    => 664,
    source  => '/vagrant/vagrant/puppet/files/www.conf',
    notify  => Service['php5-fpm'],
    require => Package['php5-fpm'],
  }

}

## Install php redis libs
class phpredis {
  require basic
  require redis

  exec { 'install_redis':
    command => 'pecl install redis',
    require => Package['php-pear'],
    onlyif  => '[ ! -f /etc/php5/fpm/conf.d/redis.ini ]'
  }

  file { '/etc/php5/fpm/conf.d/redis.ini':
    owner   => root,
    group   => root,
    mode    => 664,
    source  => '/vagrant/vagrant/puppet/files/redis.ini',
    require => Exec['install_redis'],
    notify  => Service['php5-fpm'],
  }
}

## Install latest nodejs modules, use binary 
## instead of make (which takes forever)
class { 'nodejs':
  version => 'latest',
  make_install => false,
}

## Install bower and grunt globally, these require PATH 
## updates for Puppet see line 1
class nodejs_deps {
  package { 'bower':
    provider => 'npm',
    require  => Class['nodejs'],
  }

  package { 'grunt-cli':
    provider => 'npm',
    require  => Class['nodejs'],
  }
}

## Install python dev and pip, then glue package
class glue_install {
  package { ['libjpeg62', 'libjpeg62-dev', 'zlib1g-dev', 'python-dev', 'python-pip']:
    ensure => present,
  }
  ->
  exec { 'pip_install_glue':
    command => "pip install glue",
  }
}

## Grunt runs glue so both nodejs dependencies and glue 
## are required before grunt build can run.
## Note: grunt build runs in the vagrant share root, 
## this is where the project is expected to be
class nodejs_build {
  require nodejs_deps
  require glue_install
  exec { 'npm_install':
    command => "npm install",
    cwd => "/vagrant"
  }
  exec { 'grunt_build':
    command => "grunt build",
    cwd => "/vagrant",
    require => Exec["npm_install"],
  }
}

## Install composer and build
class composer_build {
  require php54
  require phpredis
  require nodejs_build
  composer::exec { 'composer_build_install':
    cmd                  => 'install',  # REQUIRED
    cwd                  => '/vagrant', # REQUIRED
  }
}

## Run MYSQL scripts, this will DROP the dev database to avoid 
## conflict errors
class mysql {
  $grantSql = 'GRANT ALL ON *.* TO root@"%" IDENTIFIED BY "" WITH GRANT OPTION;'

  package { 'mysql-server':
    ensure => present,
  }

  service { 'mysql':
    ensure  => running,
    hasrestart => true,
    enable  => true,
    require => Package['mysql-server'],
  }

  exec { 'comment_bind_address':
    notify  => Service['mysql'],
    command => "replace 'bind-address' '#bind-address' -- /etc/mysql/my.cnf",
    require => Package['mysql-server'],
    onlyif  => "grep -c '^bind-address' /etc/mysql/my.cnf",
  }

  exec { 'grant_all':
    command => "mysql -u root -e '$grantSql'",
    require => Exec['comment_bind_address']
  }

  exec { 'create_databases':
    command => 'mysql -u root -e "DROP DATABASE IF EXISTS destiny_gg_dev; CREATE DATABASE destiny_gg_dev"',
    require => Exec['grant_all']
  }

  exec { 'install_databases':
    command => "mysql -u root destiny_gg_dev < /vagrant/config/destiny.gg.sql",
    require => Exec['create_databases']
  }

}

Exec['apt-get update'] -> Package <| |>
include basic
include redis
include php54
include phpredis
include composer_build
include nginx
include mysql

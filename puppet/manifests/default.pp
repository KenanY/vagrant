Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

class basic {

  group{ 'puppet' :
    ensure => present,
  }

  exec { 'apt-get update':
    command => 'apt-get update',
  }

  package { [ 'python-software-properties', 'build-essential' ]:
    ensure  => present,
  }

}

class nginx {
  
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

class php54 {

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

class phpredis {

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
    command => 'mysql -u root -e "CREATE DATABASE destiny_gg_dev"',
    require => Exec['grant_all']
  }

  exec { 'install_databases':
    command => "mysql -u root destiny_gg_dev < /vagrant/config/destiny.gg.sql",
    require => Exec['create_databases']
  }

}

Exec['apt-get update'] -> Package <| |>

include basic
include php54
include phpredis
include nginx
include mysql
include redis
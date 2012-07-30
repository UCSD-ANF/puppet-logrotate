# Internal: Install logrotate and configure it to read from /etc/logrotate.d
#
# Examples
#
#   include logrotate::base
class logrotate::base {
  package { 'logrotate':
    ensure => latest,
  }

  $config_basedir = '/etc'
  $config_file    = "${config_basedir}/logrotate.conf"
  $config_dir     = "${config_basedir}/logrotate.d"
  $sbindir        = $::osfamily ? {
    'Solaris' => '/opt/csw/sbin',
    default   => '/usr/sbin',
  }

  File {
    owner   => 'root',
    group   => 'root',
    require => Package['logrotate'],
  }

  file {
    $config_file :
      ensure  => file,
      mode    => '0444',
      source  => 'puppet:///modules/logrotate/etc/logrotate.conf';
    $config_dir :
      ensure  => directory,
      mode    => '0755';
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/cron.daily/logrotate':
        ensure  => file,
        mode    => '0555',
        source  => 'puppet:///modules/logrotate/etc/cron.daily/logrotate',
      }
      include logrotate::defaults::debian
    }
    'RedHat': {
      file { '/etc/cron.daily/logrotate':
        ensure  => file,
        mode    => '0555',
        source  => 'puppet:///modules/logrotate/etc/cron.daily/logrotate',
      }
    }
    'Solaris': {
      cron { 'logrotate':
        command => "${sbindir}/logrotate ${config_file}",
        user    => 'root',
        hour    => 0,
        minute  => 0,
        require => Package['logrotate'],
      }
      Package {
        provider => 'pkgutil',
      }
    }
    default: { }
  }
}

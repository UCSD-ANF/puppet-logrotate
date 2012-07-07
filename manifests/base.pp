# Internal: Install logrotate and configure it to read from /etc/logrotate.d
#
# Examples
#
#   include logrotate::base
class logrotate::base {
  package { 'logrotate':
    ensure => latest,
  }

  File {
    owner   => 'root',
    group   => 'root',
    require => Package['logrotate'],
  }

  file {
    '/etc/logrotate.conf':
      ensure  => file,
      mode    => '0444',
      source  => 'puppet:///modules/logrotate/etc/logrotate.conf';
    '/etc/logrotate.d':
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
        command => '/opt/csw/bin/logrotate',
        user    => 'root',
        hour    => 0,
        minute  => 0,
      }
      Package {
        provider => 'pkgutil',
      }
    }
    default: { }
  }
}

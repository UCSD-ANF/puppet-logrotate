# Internal: Install logrotate and configure it to read from $config_basedir/logrotate.d
#
# Examples
#
#   include logrotate::base
class logrotate::base {
  package { 'logrotate':
    ensure => latest,
  }

  $config_basedir = $::osfamily ? {
    'FreeBSD' => '/usr/local/etc',
     default  => '/etc',
  }
  $config_file    = "${config_basedir}/logrotate.conf"
  $config_dir     = "${config_basedir}/logrotate.d"
  $sbindir        = $::osfamily ? {
    'Solaris' => '/opt/csw/sbin',
    'FreeBSD' => '/usr/local/sbin',
    default   => '/usr/sbin',
  }
  $group = $::osfamily ? {
    'FreeBSD' => 'wheel',
     default  => 'root',
  }

  File {
    owner   => 'root',
    group   => $group,
    require => Package['logrotate'],
  }

  file {
    $config_file :
      ensure  => file,
      mode    => '0444',
      content  => template('logrotate/logrotate.conf.erb');
    $config_dir :
      ensure  => directory,
      mode    => '0755';
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/cron.daily/logrotate':
        ensure  => file,
        mode    => '0555',
        content => template('logrotate/logrotate.cron.erb'),
      }
      include logrotate::defaults::debian
    }
    'RedHat': {
      file { '/etc/cron.daily/logrotate':
        ensure  => file,
        mode    => '0555',
        content => template('logrotate/logrotate.cron.erb'),
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
    'FreeBSD': {
      file { '/etc/periodic/daily/601.logrotate':
        ensure  => file,
        mode    => '0555',
        content => template('logrotate/logrotate.cron.erb'),
      }
    }
    default: { }
  }
}

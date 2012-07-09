require 'spec_helper'

describe 'logrotate::base' do
  it do
    should contain_package('logrotate').with_ensure('latest')

    should contain_file('/etc/logrotate.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
      'source'  => 'puppet:///modules/logrotate/etc/logrotate.conf',
      'require' => 'Package[logrotate]',
    })

    should contain_file('/etc/logrotate.d').with({
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => 'Package[logrotate]',
    })

  end

  context 'on Debian' do
    let(:facts) { {:operatingsystem => 'Debian'} }
    let(:facts) { {:osfamily => 'Debian'} }

    it do
      should include_class('logrotate::defaults::debian')

      should_not contain_cron('logrotate')

      should contain_file('/etc/cron.daily/logrotate').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0555',
        'source'  => 'puppet:///modules/logrotate/etc/cron.daily/logrotate',
        'require' => 'Package[logrotate]',
      })
    end

  end

  context 'on RedHat' do
    let(:facts) { {:operatingsystem => 'RedHat'} }
    let(:facts) { {:osfamily => 'RedHat'} }

    it do
      should_not include_class('logrotate::defaults::debian')

      should_not contain_cron('logrotate')

      should contain_file('/etc/cron.daily/logrotate').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0555',
        'source'  => 'puppet:///modules/logrotate/etc/cron.daily/logrotate',
        'require' => 'Package[logrotate]',
      })

    end

  end

  context 'on Solaris' do
    let(:facts) { {:operatingsystem => 'Solaris'} }
    let(:facts) { {:osfamily => 'Solaris'} }

    it do
      should_not include_class('logrotate::defaults::debian')

      should contain_cron( 'logrotate').with({
        'command' => '/opt/csw/bin/logrotate',
        'user'    => 'root',
        'hour'    => 0,
        'minute'  => 0,
      })

      should_not contain_file('/etc/cron.daily/logrotate')

    end

  end

end

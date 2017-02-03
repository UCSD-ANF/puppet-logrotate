require 'spec_helper'

describe 'logrotate::base' do

  extend RSpec::SharedContext

  shared_examples_for 'Supported Platform' do
    it { should contain_package('logrotate').with_ensure('latest') }
  end

  shared_examples_for 'Linux' do
    it behaves_like 'Supported Platform'
    it { should contain_file('/etc/logrotate.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
      'source'  => 'puppet:///modules/logrotate/etc/logrotate.conf',
      'require' => 'Package[logrotate]',
    }) }

    it { should contain_file('/etc/logrotate.d').with({
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => 'Package[logrotate]',
    }) }

    it { should contain_file('/etc/cron.daily/logrotate').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0555',
      'content' => '/usr/sbin/logrotate /etc/logrotate.conf',
      'require' => 'Package[logrotate]',
    }) }

  end


  context 'on Debian' do
    let(:facts) { {
      :operatingsystem => 'Debian',
      :osfamily => 'Debian',
    } }

    it behaves_like 'Linux'
    it { should contain_class('logrotate::defaults::debian') }

    it { should_not contain_cron('logrotate') }

  end

  context 'on RedHat' do
    let(:facts) { {
      :operatingsystem => 'RedHat',
      :osfamily => 'RedHat',
    } }

    it behaves_like 'Linux'
    it { should_not contain_class('logrotate::defaults::debian') }

    it { should_not contain_cron('logrotate') }

  end

  context 'on FreeBSD' do
    let(:facts) { {
      :operatingsystem => 'FreeBSD',
      :osfamily        => 'FreeBSD',
    } }

    it behaves_like 'Supported Platform'

    it { should contain_file('/etc/cron.daily/logrotate').with({
      :ensure   => 'file',
      :owner    => 'root',
      :group    => 'wheel',
      :mode     => '0555',
      :content  => '/usr/local/sbin/logrotate /usr/local/etc/logrotate.conf',
      :require  => 'Package[logrotate]',
    }) }

  end

  context 'on Solaris' do
    let(:facts) { {
      :operatingsystem => 'Solaris',
      :osfamily        => 'Solaris',
    } }

    it behaves_like 'Supported Platform'
    it { should contain_package('logrotate').with_provider('pkgutil') }
    it { should_not contain_class('logrotate::defaults::debian') }

    it { should contain_cron( 'logrotate').with({
      'command' => '/opt/csw/sbin/logrotate /etc/logrotate.conf',
      'user'    => 'root',
      'hour'    => 0,
      'minute'  => 0,
      'require' => 'Package[logrotate]',
    }) }

    it { should_not contain_file('/etc/cron.daily/logrotate') }
  end

end

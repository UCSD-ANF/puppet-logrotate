require 'spec_helper'

describe 'logrotate' do
  it { should include_class('logrotate::base') }
end

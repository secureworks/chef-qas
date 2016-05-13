require 'spec_helper'
set :backend, :exec

describe 'qas::default' do
  describe process('.vasd') do
    it { should be_running }
  end
  describe file('/etc/profile.d/quest-path.csh') do
    it { should be_file }
  end
  describe file('/etc/profile.d/quest-path.sh') do
    it { should be_file }
  end
end

if os[:release].to_i > 6
  describe command('semodule -l') do
    its(:stdout) { should match(/vasd/) }
  end
end

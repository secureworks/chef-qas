#
# Cookbook Name:: qas
# Spec:: default
#
# Copyright 2016 Secureworks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'qas::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['qas']['quest_bin'] = '/opt/quest/bin'

        # Execute resource
        stub_command('/opt/quest/bin/vastool flush').and_return(true)
        stub_command('/opt/quest/bin/vgptool apply').and_return(true)
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run
    end

    it 'installs the vasclnt/vasgp packages' do
      expect(chef_run).to install_package('vasclnt, vasgp')
    end

    it 'creates the quest-path templates' do
      expect(chef_run).to render_file('/etc/profile.d/quest-path.sh')
      expect(chef_run).to render_file('/etc/profile.d/quest-path.csh')
    end

    context 'includes the selinux recipe when node.platform_version > 6' do
      cached(:chef_run) do
        node.automatic['platform_version'] = '7.1'
        expect(chef_run).to include_recipe('qas::selinux')
      end
    end

    context 'raises an exception when hostname is localhost' do
      cached(:chef_run) do
        node.automatic['hostname'] = 'localhost'
        expect(chef_run).to raise_error(RuntimeError)
      end
    end
  end
end

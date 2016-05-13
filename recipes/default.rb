#
# Cookbook Name:: qas
# Recipe:: default
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

raise 'Hostname is not set! Please set the system\'s hostname and try again' if node['hostname'] =~ /localhost/

package %w( vasclnt vasgp )

%w( quest-path.sh quest-path.csh ).each do |env_file|
  template "/etc/profile.d/#{env_file}" do
    source "#{env_file}.erb"
    mode '0755'
  end
end

service 'sshd' do
  action :nothing
  supports status: 'true', start: 'true', stop: 'true', restart: 'true'
end

service 'vasd' do
  action :start
  supports status: 'true', start: 'true', stop: 'true', restart: 'true'
end

include_recipe 'qas::selinux' if node['platform_version'].to_i > 6
include_recipe 'qas::qas_ohai_plugin'

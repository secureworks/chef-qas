#
# Cookbook Name:: qas
# Recipe:: selinux
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

# To hork in the restorecon helper from selinux_policy cookbook...
::Chef::Recipe.send(:include, Qas::Restorecon)

modules = Mixlib::ShellOut.new('semodule -l')
modules.run_command

if !modules.stdout.include?('vasd')
  package('selinux-policy-devel').run_action(:install)

  directory '/tmp/vasd_selinux' do
    owner 'root'
    group 'root'
    mode '0700'
    action :create
  end.run_action(:create)

  %w( vasd.fc vasd.if vasd.te ).each do |file|
    cookbook_file(file) { path "/tmp/vasd_selinux/#{file}" }.run_action(:create)
  end

  make_semodule('/tmp/vasd_selinux')
  semodule('-i', '/tmp/vasd_selinux/vasd.pp')

  selinux_policy_fcontext '/var/opt/quest/vas/vasd(/.*)?' do
    secontext 'vasd_var_auth_t'
  end

  %w( /home/ /etc/rc.d/init.d/vasd /etc/init.d/vasd /opt/quest/
      /var/opt/quest/ /etc/opt/quest/ ).each do |dir|
    restorecon(dir)
  end
else
  Chef::Log.info('SELinux module installed - skipping compile/install')
end

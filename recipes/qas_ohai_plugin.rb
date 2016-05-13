#
# Cookbook Name:: qas
# Recipe:: qas_ohai_plugin
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
include_recipe 'ohai::default'

ohai 'reload_packages' do
  action :nothing
end

directory node['ohai']['plugin_path'] do
  action :create
end

cookbook_file "#{node['ohai']['plugin_path']}/qas.rb" do
  source 'qas.rb'
  action :create
  group 'root'
  user 'root'
  notifies :reload, 'ohai[reload_packages]', :immediately
end

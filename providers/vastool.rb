# Support whyrun
def whyrun_supported?
  true
end

use_inline_resources

action :join do
  user = new_resource.user
  pass = new_resource.pass
  fqdn = new_resource.fqdn
  domain = new_resource.domain
  vastool = "#{node['qas']['quest_bin']}/vastool"
  vgptool = "#{node['qas']['quest_bin']}/vgptool"
  join_args = " -u '#{user}' -w '#{pass}' join -f -n '#{fqdn}' "

  if old_ou && vas_configured?
    baseou = old_ou
  else
    baseou = new_resource.baseou
  end
  ou_arg = " -c '#{baseou}' "

  unless vas_configured?
    timesync = Mixlib::ShellOut.new(vastool + " timesync -d #{domain}")
    timesync.run_command

    join = Mixlib::ShellOut.new(vastool + join_args + ou_arg + domain)
    join.run_command
    unless join.status.exitstatus == 0 # Machine account exists? Re-join without specifying OU
      failsafe = Mixlib::ShellOut.new(vastool + join_args + domain)
      failsafe.run_command
      failsafe.error!
      err = "Initial join to #{baseou} failed, joined without specifying an OU"
      Chef::Log.warn(err)
    end
    Chef::Log.warn("Joined #{domain} as #{fqdn}")

    execute('vastool-flush') { command lazy { vastool + ' flush' } }
    execute('vgptool-apply') { command lazy { vgptool + ' apply' } }
    configure_krb5 if node['qas']['configure_kerberos'] == true
    new_resource.updated_by_last_action(true)
  end
end

# I'm using a case statement in this method because vastool is kind of
# ridiculous about exit codes. I know for sure that kinit returns 10 on an
# unconfigured install and leaving the option to recognize more exit codes
# at a later date seems prudent.
def vas_configured?
  kinit = Mixlib::ShellOut.new("#{node['qas']['quest_bin']}/vastool -u host/ kinit")
  kinit.run_command
  case kinit.status.exitstatus
  when 10
    kinit_status = false
  else
    kinit_status = true
  end
  kinit_status
end

def old_ou
  info_id = Mixlib::ShellOut.new("#{node['qas']['quest_bin']}/vastool -u host/ info id")
  begin
    info_id.run_command
    info_id_array = info_id.stdout.split(',')[1]
    ou = info_id_array.join(',').chomp if info_id_array.grep('DC=')
  rescue
    ou = nil
  end
  ou
end

def configure_krb5
  file '/etc/krb5.conf' do
    action :delete
    not_if 'test -h /etc/krb5.conf'
  end

  link '/etc/krb5.conf' do
    to '/etc/opt/quest/vas/vas.conf'
    notifies :run, 'execute[toconf]', :immediately
  end

  execute 'toconf' do
    command "#{node['qas']['quest_bin']}/vastool -u host/ info toconf /etc/krb5.conf"
    action :nothing
  end
end

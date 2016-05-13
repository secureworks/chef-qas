#
# Author:: Zach Morgan <zmorgan@secureworks.com>
# License:: Apache License, Version 2.0
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
## See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:Qas) do
  provides 'etc/qas'
  depends 'etc'

  def group?(name)
    cmd = Mixlib::ShellOut.new("/opt/quest/bin/vastool list group #{name}").run_command
    return true if cmd.status.exitstatus == 0
  end

  def parse_group(name)
    cmd = Mixlib::ShellOut.new("/opt/quest/bin/vastool list group #{name}").run_command
    output = cmd.stdout.split(/:/).last(2)
    { gid: output[0], members: output[1] }
  end

  def find_name(line)
    line.gsub!(/@.*/, '') if line.include?('@')
    line.gsub!(/.*\\\\/, '') if line.include?('\\\\')
    line.gsub!(/.*\\/, '') if line.include?('\\')
    line
  end

  def local_user?(uname)
    local_users = %w(root bin daemon adm lp sync shutdown
                     halt mail news uucp operator games gopher
                     ftp nobody nscd vcsa pcap rpc mailnull smmsp
                     ntp sshd dbus avahi named xfs rpcuser nfsnobody
                     haldaemon avahi-autoipd abrt tcpdump
                     saslauth postfix arpwatch nslcd)
    uname unless local_users.include?(uname)
  end

  collect_data(:default) do
    etc['qas'] = Mash.new
    etc['qas']['users-allowed'] = Mash.new
    etc['qas']['groups'] = Mash.new
    etc['qas']['local-users'] = Mash.new
    users = {}
    local = {}
    groups = []

    # Gather users-allowed data.
    # output looks like:
    # DOMAIN\\joejack:VAS:1438883976:4000::/home/joejack:/bin/bash
    fh = Mixlib::ShellOut.new('/opt/quest/bin/vastool list users-allowed').run_command
    fh.stdout.lines do |line|
      fields = line.split(/:/)
      users[find_name(fields[0])] = {
        uid: fields[2],
        home: fields[5],
        shell: fields[6].chomp
      } if fields.length > 6
    end

    # Gather groups by parsing /etc/opt/quest/vas/users.allow. Entries can be in
    # DOMAIN\group or group@DOMAIN format, so we use the find_name method to grab the
    # samAccountName for the group and then validate it with vastool list group.
    # Finally, we construct a hash of the name => GID, members and populate the node attr
    File.read('/etc/opt/quest/vas/users.allow').lines do |line|
      name = find_name(line)
      groups << { name.chomp => parse_group(name) } if group?(name)
    end

    # Gather local users by parsing /etc/passwd
    File.read('/etc/passwd').lines do |line|
      name = line.split(/:/)[0]
      uid = line.split(/:/)[2]
      home = line.split(/:/)[5]
      shell = line.split(/:/)[6]
      local[name] = { uid: uid, home: home, shell: shell.chomp } if local_user?(name)
    end

    etc['qas']['users-allowed'] = users
    etc['qas']['groups'] = groups
    etc['qas']['local-users'] = local
  end
end

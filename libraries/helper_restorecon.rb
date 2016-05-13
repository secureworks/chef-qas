# Cookbook: qas
# Library: helper-restorecon
# Ripped blatantly from the selinux_policy cookbook,
# with major modifications for our environment.
# 2015, GPLv2, Joerg Herzinger (www.bytesource.net)

module Qas
  # Returns the system command for restorecon
  module Restorecon
    def restorecon(file_spec)
      path = file_spec.to_s.sub(/\\/, '') # Remove backslashes
      e = execute(path) do
        command lazy { "restorecon -Fv #{path}" }
        only_if { ::File.exist?(path) }
        not_if { ::File.directory?(path) }
      end
      return if e.updated_by_last_action?
      execute(path) { command lazy { "restorecon -FRv #{path}" } }
    end

    def semodule(args, file)
      execute('s') { command "semodule #{args} #{file}" } if ::File.exist?(file)
    end

    def make_semodule(dir)
      execute('make') do
        command "cd #{dir} && make -f /usr/share/selinux/devel/Makefile"
      end.run_action(:run)
    end
  end
end

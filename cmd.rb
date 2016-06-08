
def main
	fail_cmd = "rmdir aa-#{rand.to_s}"

	s = SSHCmdHelper.new 'reednj@popacular.com'

	puts s.exec ['echo "START"', fail_cmd ,'echo "FINISH"']

end


class SSHCmdHelper
	def initialize(server)
		@server = server
	end

	def exec(cmd)
		cmd = cmd.join ' && ' if cmd.is_a? Array
		CmdHelper.exec "ssh #{@server} '#{cmd}'"
	end

	def scp(from, to)
		`scp #{from} #{@server}:#{to}`
	end
end

class CmdHelper
	# runs a shell command in such a way that if it fails (according to the exit status)
	# and exception will be raised with the stderr output
	def self.exec(cmd)
		output = `(#{cmd}) 2>&1`
		raise "#{output}" if $?.exitstatus != 0
		return output
	end
end

main
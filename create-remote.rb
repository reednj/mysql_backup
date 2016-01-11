#!env ruby

class App
	def main
		@server = SSHCmd.new 'reednj@fb.reednj.com'
		@site_name = 'fb.reednj.com'
		@code_path = '~/code'
		@repo_name = "#{@site_name}.git"

		puts 'creating remote repository'
		self.create_repo

		puts 'copying post-receive hook'
		self.copy_hook

		puts 'done'
	end

	def repo_path
		File.join @code_path, @repo_name
	end

	def create_repo
		
		@server.exec [
			"cd #{@code_path}", 
			"mkdir #{@repo_name}", 
			"cd #{@repo_name}",
			'git init',
			'git config receive.denyCurrentBranch ignore'
		]

	end

	def copy_hook
		# scp $SCRIPTS_DIR/hooks/post-receive.rb $REMOTE_HOST:$REMOTE_DIR/$REPOSITORY_NAME/.git/hooks/post-receive
		@server.scp 'hooks/post-receive.rb', "#{repo_path}/.git/hooks/post-receive"
	end

end

class SSHCmd
	def initialize(server)
		@server = server
	end

	def exec(cmd)
		cmd = cmd.join ';' if cmd.is_a? Array
		`ssh #{@server} '#{cmd}'`
	end

	def scp(from, to)
		`scp #{from} #{@server}:#{to}`
	end
end

App.new.main

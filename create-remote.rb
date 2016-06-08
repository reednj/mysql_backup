#!/usr/bin/env ruby

class App
	def main
		if ARGV.length != 2
			usage
			return
		end

		@server = SSHCmd.new ARGV[1]
		@site_name = ARGV[0]
		@repo_name = "#{@site_name}.git"
		@code_path = '~/code'
		
		if repo_exist?
			puts "remote repository already exists (#{repo_path})"
			return
		end

		puts 'creating remote repository'
		self.create_repo

		puts 'copying post-receive hook'
		self.copy_hook

		puts 'done'
	end

	def usage
		puts "A script for creating prod deployment remotes with git"
		puts "Nathan Reed (c) 2015"
		puts "Usage:"
		puts "\tcreate-remote <repo-name> <remote-name>"
		puts ""
		puts "Example:"
		puts "\tcreate-remote redditstream reednj@reddit-stream.com"
	end

	def repo_exist?
		@server.exec("test -d #{repo_path} && echo 1").include? '1'
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
		hook_path = "#{repo_path}/.git/hooks/post-receive"
		@server.scp 'hooks/post-receive.rb', hook_path
		@server.exec "chmod 775 #{hook_path}"
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

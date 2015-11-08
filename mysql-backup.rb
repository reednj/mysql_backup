#!/usr/bin/env ruby

def load_relative(path)
	file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
	load File.expand_path path, File.dirname(file)
end

require 'rubygems'
require 'ostruct'
require 'fileutils'
require 'json'
require 'yaml'
require 'trollop'

load_relative './shared/extensions.rb'

class BackupConfig
	def initialize(config)
		try_load ['app.config.rb', './config/app.config.rb', '../config/app.config.rb']

		@config = config
		_validate!

	end

	def self.load_from(path)
		data = YAML.load_file(path)
		BackupConfig.new data
	end

	def _validate!
		raise 'config object required' if @config.nil?
		raise 'server required' if server.nil?
		raise 'username required' if username.nil?
		raise 'database required' if database.nil?
		raise 'backup destination required' if save_to.nil?
	end

	def server
		@config['server']
	end

	def username
		@config['username'] || (app_config? ? AppConfig.db[:username] : nil)
	end

	def password
		pw = @config[:password] || (app_config? ? AppConfig.db[:password] : nil)
		return nil if pw.nil? || pw.strip == ''
		return pw
	end

	def database
		@config['database']
	end

	def password?
		!password.nil?
	end

	def tables
		Array.from @config['tables']
	end

	def save_to
		Array.from @config['save_to']
	end

	def app_config?
		!!defined?(AppConfig) && !AppConfig.nil? && !AppConfig.db.nil? && AppConfig.db[:database] == self.database
	end

end

class App
	def main
		v = 'v0.1.0'

		opts = Trollop::options do
			version "mysql-backup #{v} (c) 2015 @reednj"
			opt :config, "YAML config file", :type => :string
			opt :output, "Name of backup output file", :type => :string
		end

		@seed = (rand() * 10000).round.to_s

		begin
			config_path = opts[:config] || 'mysql-backup.conf'
			@config = BackupConfig.load_from config_path
		rescue => e
			puts "Error: Could not load config file at '#{config_path}' - #{e.message}"
			return
		end
		
		self.create_backup

		@config.save_to.each do |path|
			begin
				self.save path
				puts File.join(path, filename)
			rescue => e
				puts "Could not save backup to #{path} - #{e.message}"
			end
		end

		self.clean
	end

	def create_backup
		password = ''
		password = "-p#{@config.password}" if @config.password?
		options = '--no-create-info --skip-comments'
		tables = @config.tables.join ' '
		run! "mysqldump -u #{@config.username} #{password} --host=#{@config.server} #{options} #{@config.database} #{tables} | gzip > #{tmp_path}; exit ${PIPESTATUS[0]}"
	end

	def save(to_dir)
		if _remote_path? to_dir
			dest = File.join(to_dir, filename)
			run! "scp #{tmp_path} #{dest}"
		else
			p = File.expand_path to_dir
			dest = File.join(p, filename)
			FileUtils.copy tmp_path, dest
		end
	end

	def clean
		File.delete tmp_path
	end

	def filename
		"#{@config.database}.#{@seed}.sql.gz"
	end

	def tmp_path
		"/tmp/mysql.#{@seed}.bak"
	end

	# runs a shell command in such a way that if it fails (according to the exit status)
	# and exception will be raised with the stderr output
	def run!(cmd)
		output = `(#{cmd}) 2>&1`
		raise "#{output}" if $?.exitstatus != 0
	end

	# is this path on a remote server? do we need to use scp to copy the backup there?
	def _remote_path?(path)
		# not exactly foolproof, but it will do for now
		path.include? ':'
	end
end

App.new.main


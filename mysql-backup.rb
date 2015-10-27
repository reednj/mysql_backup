#!/usr/bin/env ruby

require 'rubygems'
require 'ostruct'
require 'fileutils'
require 'json'

require_relative './shared/extensions'


class BackupConfig
	def initialize(config)
		_validate! config
		@config = config
	end

	def self.load(path = nil)
		return self.load('./mysql-backup.conf') if path.nil?
		data = File.read path
		obj = JSON.parse(data, {:symbolize_names => true})
		return self.new obj
	end

	def _validate!(config)
		raise 'config object required' if config.nil?
		raise 'server required' if config[:server].nil?
		raise 'username required' if config[:server].nil?
		raise 'database required' if config[:database].nil?
		raise 'backup destination required' if config[:save_to].nil?
	end

	def server
		@config[:server]
	end

	def username
		@config[:username]
	end

	def password
		@config[:password]
	end

	def database
		@config[:database]
	end

	def password?
		!(@config[:password].nil? || @config[:password] == '')
	end

	def tables
		Array.from @config[:tables]
	end

	def save_to
		Array.from @config[:save_to]
	end

end

class App
	def main
		@config = BackupConfig.load
		@seed = (rand() * 10000).round.to_s

		self.create_backup

		@config.save_to.each do |path|
			begin
				self.save path
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
		`mysqldump -u #{@config.username} #{password} --host=#{@config.server} #{options} #{@config.database} #{tables} | gzip > #{tmp_path}`
	end

	def save(to_dir)
		if _remote_path? to_dir
			dest = File.join(to_dir, filename)
			`scp #{tmp_path} #{dest}`
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

	def _remote_path?(path)
		# not exactly foolproof, but it will do for now
		path.include? ':'
	end
end

App.new.main


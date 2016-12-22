require 'ostruct'
require 'fileutils'
require 'json'
require 'yaml'
require 'time'

require './shared/extensions.rb'

module MysqlBackup
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
			pw = @config['password'] || (app_config? ? AppConfig.db[:password] : nil)
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

end
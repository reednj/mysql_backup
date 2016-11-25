#!/usr/bin/env ruby

require 'fileutils'

class App
	def main
		files = ['add-ssh.sh', 'mysql-backup.rb', 'delete-old.rb']

		self.add_bin_dir

		files.each do |file|

			if File.exist? file
				puts "adding #{file}"
				self.make_exec file
				self.add_bin_link file
			else
				puts "error: couldn't find #{file}"
			end
		end
	end

	def add_bin_dir
		`mkdir -p ~/bin`
	end

	def add_bin_link(file)
		path = File.expand_path(file, '.').fix_win_path
		bin_path = File.expand_path('~/bin').fix_win_path
		bin_name = File.basename file, File.extname(file)
		link_path = File.join(bin_path, bin_name)

		if File.exist? link_path
			puts "#{link_path} exists"
		else
			FileUtils.ln_s path, link_path
		end
	end

	def make_exec(file)
		`chmod 750 #{file}`
	end
end

class String
	def fix_win_path
		return self.gsub 'C:/', '/c/'
	end
end

App.new.main

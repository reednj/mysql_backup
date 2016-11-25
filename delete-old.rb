#!/usr/bin/env ruby

require 'trollop'

class App
	def main
		opts = Trollop::options do
			version "delete-old (c) 2016 @reednj"
			opt :wildcard, "wildcard for filename matching", :type => :string, :default => '*.gz'
			opt :path, "path to search", :type => :string
			opt :age, "match any files older than this (ex. 1d, 36h)", :default => '28d'
			opt :test, "print the list of matched files, but don't delete"
		end

		ext = opts[:wildcard] || '*.gz'
		max_age = opts[:age].to_duration
		path = opts[:path] || '.'
		path = path + '/' if path.last != '/'
		matched = Dir["#{path}#{ext}"].select {|f| File.mtime(f).age > max_age }

		puts 'Listing files only, will not delete' if opts[:test]
		matched.each do |f|
			File.delete(f) if !opts[:test]
			puts f
		end
	end
end

class String
	def to_duration
		s = self.gsub(' ', '').strip
		unit = s.last
		ord = s.chomp(unit).to_f
		
		second = 1.0
		minute = second * 60
		hour = minute * 60
		day = hour * 24
		week = day * 7

		return ord * week if unit == 'w'
		return ord * day if unit == 'd'
		return ord * hour if unit == 'h'
		return ord * minute if unit == 'm'
		return ord * second if unit == 's'
		raise "could not parse duration #{self}"
	end

	def last
		self[-1, 1]
	end
end

class Time
	def age
		Time.now - self
	end
end

App.new.main

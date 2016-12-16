#!/usr/bin/env ruby

class ProcHelper
	def self.find(name)
		`pgrep -f #{name}`.split(' ').map { |p| p.to_i }
	end

	def self.find_only(name)
		a = find(name)
		raise "more than one matching process for '#{name}': [#{a.join ', '}]" if a.length > 1
		a.first
	end
end

def if_no(process_name, options={})
	begin
		pid = ProcHelper.find_only(process_name)

		if pid.nil?
			if options[:run].nil?
				$stderr.puts "no matching process for '#{process_name}'" 
			else
				system options[:run]
			end			
		else
			$stderr.puts "'#{process_name}' found with pid #{pid}"
		end
	rescue => e
		$stderr.puts "error: #{e}"
	end
end

if_no 'sleep', :run => 'sleep 100 &'
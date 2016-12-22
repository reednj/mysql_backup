
def try_load_file(path)
	begin
		load_relative path
		return path
	rescue LoadError => e
		return nil
	end
end

def try_load(paths)
	Array.from(paths).each do |path|
		result = try_load_file path
		return result if !result.nil?
	end

	return nil
end

def this_dir
	file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
	File.expand_path File.dirname(file)
end

def load_relative(path)
	load File.expand_path path, this_dir()
end

class Array
	def self.from(a)
		return a if a.is_a? Array
		return [] if a.nil?
		return [a]
	end
end

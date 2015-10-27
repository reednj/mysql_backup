
def try_load_file(path)
	begin
		load path
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

class Array
	def self.from(a)
		return a if a.is_a? Array
		return [] if a.nil?
		return [a]
	end
end

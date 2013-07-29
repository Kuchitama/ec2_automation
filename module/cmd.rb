class CMD
	def self.execute(cmd)
		result = `#{cmd}`
    
		puts result
    
		if $? != 0 
			raise "finish #{$?} : '#{cmd}'"
		end
	end
end

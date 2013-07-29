require 'rubygems'
require 'yaml'
require 'aws-sdk'

class AWSConfig
	attr_reader :config

	def initialize(path = File.join(File.dirname(__FILE__), "../config.yml"))
		checkExist(path)
		@config = YAML.load(File.read(path))
		checkHash
	end

	def checkExist(file_path)
		unless File.exist?(file_path)
			puts <<END
config.yml is not found.

1. run a command below.
'mv config.yml.template config.yml'
2. you edit 'config.yml'
3. rerun this script.
END
			exit 1
		end
	end


	def checkHash
		unless @config.kind_of?(Hash)
			push <<END
config.yml is formatted incorrectly. Please use the config.yml.template.
END
			exit 1
		end
	end

	
	private :checkExist, :checkHash
end


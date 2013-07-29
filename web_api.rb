require 'sinatra'
require 'eventmachine'
require File.expand_path(File.dirname(__FILE__) + '/module/cmd')

set :bind, '0.0.0.0'
set :port, 8080

get '/' do
	""
end

get '/build' do
	cmd = <<END
git pull &&
ruby #{File::dirname(__FILE__)}'/run_instance.rb'"
END
	puts cmd

	EM::defer do
		CMD::execute(cmd)
	end

	"start updating your ami"
end

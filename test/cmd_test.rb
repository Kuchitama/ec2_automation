require 'rubygems'
require 'rspec'
require './module/cmd.rb'

describe CMD, "execute shell command" do
	it "should execute command" do
		CMD::execute("ls")

		$?.should == 0
	end
end

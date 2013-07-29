# -*- coding: utf-8 -*-

require 'rubygems'
require 'rspec'
require './module/load_config.rb'

describe AWSConfig do
	before do
		@config = AWSConfig.new(File::join(File::dirname(__FILE__),"test.yml"))
	end

	it "config should not nil" do
		@config.config.should_not == nil
	end

	it "undefined key should return nil" do
		@config.config['__undefined__'].should == nil
	end

	it "should create hash from file" do
		@expect = {
			"access_key_id" => "__access_key__",
			"secret_access_key" => "__secret_access_key__",
			"region" => "__region__",
			"user" => "__user__",
			"key" => "__key__",
			"key_pair" => "__key_pair__",
			"image_id" => "__image_id__",
			"security_group_ids" => ["__security_group_id1__"]
		}

		@config.config.should == @expect
	end
end

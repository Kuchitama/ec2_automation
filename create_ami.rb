# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/module/load_config')
require File.expand_path(File.dirname(__FILE__) + '/module/cmd')

require 'net/http'
require 'net/ssh'

instance = key_pair = group = nil

# config
	config = AWSConfig.new.config
	AWS.config(config)

	def get_key_expand_path(current_path, path)
		if path.start_with?("/")
			path
		else
			File.expand_path(File::join(current_path, path))
		end
	end
	
	@key = get_key_expand_path(File.dirname(__FILE__), config['key'])
	
	if !File.exist?(@key)
		puts <<END
file[#{@key}] is not exits
END
		exit 1
	end


begin
	ec2 = AWS::EC2.new

	key_pair = ec2.key_pairs[config["key_pair"]]
	puts "use keypair #{key_pair.name}, fingerprint: #{key_pair.fingerprint}"

	if !File.exists?(@key)
		raise "#{@key} is not exist"
	end

###	# launch the instance
	instance = ec2.instances.create({
		:image_id => config["image_id"],
		:security_group_ids => config["security_group_ids"], 
		:instance_type => "t1.micro",
		:key_pair => key_pair
	})

	sleep 10 while instance.status == :pending
	puts "Launched instance #{instance.id}, status: #{instance.status}"

	exit 1 unless instance.status == :running
	puts "sleeping ....."
	sleep 30

	begin
		puts "access to #{instance.dns_name} with ssh as ec2-user using identify key [#{@key}]"
		Net::SSH.start(instance.dns_name,config["user"] , 
							{:keys => [@key], :timeout => 30}) do |ssh|
			puts "Running 'uname -a' on the instance yields:"
			puts ssh.exec!("uname -a")
		end
	rescue SystemCallError, Timeout::Error => e
		# port 22 might not be available immediately after the instance finishes launching
		sleep 1
		retry
	end

	script_dir = File.dirname(__FILE__) 

	prepare_cmd = <<END
cp #{script_dir}/template.json #{script_dir}/chef-repo/nodes/#{instance.dns_name}.json &&
cd #{script_dir}/chef-repo &&
knife solo prepare ec2-user@#{instance.dns_name} -i #{@key} 
END

	puts "copy #{script_dir}/template.json to #{script_dir}/chef-repo/nodes/#{instance.dns_name}.json" 
	puts "Prepare chef solo at #{instance.dns_name}"
	CMD::execute(prepare_cmd)

	cook_cmd = <<END
cd #{script_dir}/chef-repo &&
knife solo cook ec2-user@#{instance.dns_name} -i #{@key}
END

	CMD::execute(cook_cmd)

	image_name = "base_#{Time.now.strftime("%Y/%m/%d-%H%M")}"
	comments = "automatically generated image"

	puts "create image: name[" + image_name + "]"
	instance.create_image(image_name, {:instance_id => instance.id, :description => comments, :no_reboot => true})
	puts "created image!"

ensure
	# clean up
	[instance].compact.each(&:delete)
end

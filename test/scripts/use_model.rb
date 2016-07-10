#gem 'libxml-ruby', '= 0.3.8.4'
require File.dirname(__FILE__) + '/../../lib/vz'
require 'breakpoint'

Vz.logger.level = Logger::DEBUG

puts "Using Node..."
start_time = Time.now
@node = Vz::MasterNode.new( ARGV.shift, :username => ARGV.shift, :password => ARGV.shift )
puts " Connecting: #{Time.now - start_time} seconds"

puts "Get containers..."

# start_time = Time.now
# envs = @node.containers( :include => :resources )
# puts " Preloading: Total Timing: #{Time.now - start_time} seconds for #{envs.length} containers"
#
# start_time = Time.now
# envs = @node.containers.each { |env| env.cpu_load; env.memory }
# puts " No Preloading: Total Timing: #{Time.now - start_time} seconds for #{envs.length} containers"


@envs = @node.containers( :include => :resources )

@envs.each_with_index { |env, idx| instance_variable_set("@env_#{idx}".to_sym, env) }
puts "Set #{@envs.size} container instance variables"


#@samples  = @node.connection.env_samplem.get_sample_conf().map { |s| Vz::SampleConfiguration.from_connector( s ) }
#@nag      = @samples.find { |f| f.name == "Nagilum.256K" }

#@new_env = Vz::Container.new( :hostname => 'testnew.nagilumgroup.com', :sample_configuration_id => @nag.id )
breakpoint

#env.nameservers << '123.444.223.121'
#env.qos.first.soft_limit = '666'
#puts "IP Addresses: #{env.ip_addresses.inspect}"
#env.ip_addresses << Vz::IpAddress.new( :ip => '11.22.33.445' )

#puts env.inspect

#puts env.to_changed_connector_hash.inspect
#puts env.net_devices.inspect


#envs.each do |env|
#  puts "Container #{env.eid}"
#  puts "RAs: #{env.remote_attributes.inspect}"
#  env.remote_attributes.each do |ra|
#    if ra == :qos
#      puts "Qos --------------------------> "
#      env.qos.each do |q|
#        puts "    #{q.id.rjust(20)}: #{(q.soft_limit || '').rjust(15)} | #{(q.hard_limit || '').ljust(15)} ==> #{q.current}"
#      end
#    end
#    puts "#{ra.to_s.ljust(20)}: #{env.send(ra.to_sym)}"
#  end
#  puts "---------------\n\n\n"
#end

puts "DONE!"

require File.join( File.dirname(__FILE__), '..', '..', 'lib', 'vz' )

node = Vz::Node.new(ARGV.shift, :username => ARGV.shift, :password => ARGV.shift)

env = node.containers.first

puts "Current Hostname: #{env.hostname}"
puts "Current Nameservers: #{env.nameservers.inspect}"

env.hostname = (0..10).map { rand(10) }.join
env.nameservers << '123.444.223.121'
#env.nameservers.clear

puts "Changed.... #{env.changed_attributes.inspect}"

env.save!

new_env = node.containers.first
puts "Refreshed Hostname: #{new_env.hostname}"
puts "Refreshed Nameservers: #{new_env.nameservers.inspect}"

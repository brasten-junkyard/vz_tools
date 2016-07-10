#!/usr/bin/env ruby

#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/../vz'

def output_header
  puts "ovzstat v0.1 - (c) Copyright Nagilum LLC"
  puts "-----------------------------------------------------------------"
  puts ""
end

def build_cluster
  hosts    = ARGV.shift.split(',')
  username = ARGV.shift

  @cluster = Vz::Cluster.new
  # Eventually thing would be build from a config file.
  hosts.each do |host|
    @cluster.register_node(host, :username => username, :port => 23)
  end
end

def container_list
  puts "  Containers"
  @cluster.containers.sort { |a, b| a.veid <=> b.veid }.each do |env|
    puts "    #{(env.veid.to_s || 'XXX').rjust(7)}) #{(env.hostname || 'n/a').ljust(35)} [#{(env.node.hostname || 'n/a').ljust(25)}] (#{env.status})"
  end
end

build_cluster
output_header
container_list

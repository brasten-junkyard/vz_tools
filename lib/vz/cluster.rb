#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'
require 'vz/node'

module Vz

  # Holds a cluster of nodes for cluster-wide processes.
  #
  class Cluster

    def initialize
      @container_list = {}
      @nodes = []
    end

    def nodes
      @nodes
    end

    def register_node( hostname, options={} )
      @nodes << Node.new( hostname, options ) unless @nodes.any? { |node| node.hostname == hostname }
    end

    def find_node_by_hostname( hostname )
      @nodes.find { |n| n.hostname == hostname }
    end

    def find_container_by_eid( eid )
      # First check caches
      #
      @nodes.each do |node|
        container = node.find_container_by_eid( eid )

        return container unless container.nil?
      end

      # If we're still here, there is no cached container for that VEID.
      # Brute-force tactics are required!
      #
      @nodes.each do |node|
        container = node.find_container_by_veid( veid )

        return container unless container.nil?
      end

      return false
    end

    def containers
      ves     = @nodes.map { |node| node.containers }.flatten
      @veid_map = ves.inject({}) do |memo, obj|
        memo[obj.veid] = obj.node.hostname
        memo
      end
      ves
    end



  end
end

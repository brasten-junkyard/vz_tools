#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

# Loads all files required for VZTools
$LOAD_PATH.push( File.dirname(__FILE__) )

# Standard Library requirements
#
require 'forwardable'
require 'logger'
require 'base64'

# External required gems
#
gem 'eventmachine'
gem 'facets'

require 'eventmachine'
require 'rexml/document'
require 'facets/string'

%w( cluster node master_node container cpu_info cpu_load qos
    event process_list load_average stats system_info helper error
    resource_locator sample_configuration realms realm package
    resource_info performance_data connector interface support).each do |file|

  require File.join( File.dirname(__FILE__), 'vz', file )

end

#
# === Vz
#
# The VZTools::Api module provides a full object-model API for interacting with
# OpenVZ.  The object model was intentionally modeled after the Virtuozzo XML
# API, but it is definitely not intended to be identical or compatible in any
# way.
#
# Example:
#
#   node = Vz::Node.new( 'hostname', :username => 'user', :password => 'pass' )
#   ctr  = node.find_container_by_eid( 101 )  # get Container
#
#   # start up Container
#   ctr.start!
#
#   # stop VE
#   ctr.stop!
#
module Vz
  @@logger        = Logger.new(STDOUT)
  @@logger.level  = Logger::ERROR

  class << self
    extend Forwardable

    def_delegators Vz::Support::Marshaller, :register_type, :unregister_type, :clear_registered_types!

    def logger
      @@logger
    end

    def logger=( val )
      @@logger = val
    end

    # Log something to the Vz logger.
    #
    # Arguments can be either a message (string) or a log level (symbol)
    # and message (string).  Log level defaults to debug.
    #
    # Multiple arguments (after any level arg) will be concatted, and non-Strings
    # will be 'inspect'ed.
    #
    # Examples:
    #
    #   Vz.log( "An error occured here!" )            # Logs an error as an info
    #   Vz.log( :error, "An error occured here!" )    # Logs an error as an error
    #   Vz.log( "The results are: ", results)         # Logs something like 'The results are: ["Hi", "There"]'
    #
    def log( *args )
      return false if @@logger.nil?

      level     = ( args.first.kind_of?(Symbol) ? args.shift : :debug )
      message   = args.map { |obj| obj.kind_of?(String) ? obj : obj.inspect }.join
      timestamp = Time.now.strftime('%m/%d %H:%M:%S')

      @@logger.send(level, message)
    end

    def encode( val )
      Base64.encode64( val )
    end

    def decode( val )
      Base64.decode64( val )
    end

  end

  class ConsoleLogger
    def method_missing( sym, *args, &block )
      puts "[#{sym.to_s.upcase}] #{args.first}"
    end
  end

  register_type(Vz::Connector::Packet)
end

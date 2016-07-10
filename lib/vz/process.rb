#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'base64'

module Vz
  class Process
    include Vz::Helper::ActiveVz

    KILL      = 9
    QUIT      = 3
    ABORT     = 6
    TERM      = 15

    attr_accessor :eid
    attr_accessor :locator
    attr_accessor :names

    def pid
      REXML::XPath.first( @document, './*[local-name()="pid"]').text.to_i
    end

    def cpu_usage
      Base64.decode64( REXML::XPath.first( @document, xpath_for('%cpu') ).text ).to_f
    end

    def memory_usage
      Base64.decode64( REXML::XPath.first( @document, xpath_for('%mem') ).text ).to_f
    end

    def command
      Base64.decode64( REXML::XPath.first( @document,  xpath_for('command') ).text )
    end

    def nice
      Base64.decode64( REXML::XPath.first( @document, xpath_for('ni') ).text )
    end

    def priority
      Base64.decode64( REXML::XPath.first( @document, xpath_for('pri') ).text ).to_i
    end

    def physical_memory
      Base64.decode64( REXML::XPath.first( @document, xpath_for('rss') ).text ).to_i
    end

    def status
      Base64.decode64( REXML::XPath.first( @document, xpath_for('stat') ).text )
    end

    def time
      Base64.decode64( REXML::XPath.first( @document, xpath_for('time') ).text )
    end

    def user
      Base64.decode64( REXML::XPath.first( @document, xpath_for('user') ).text )
    end

    def kill!( signal=KILL )
      locator.services(:vzaprocessm).kill( :eid => self.eid, :pid => self.pid, :signal => signal )
    end

    private

      def xpath_for( value )
        './*[local-name()="param"][' + (index_for(value) + 1).to_s + ']'
      end

      def index_for( value )
        @names.index( value )
      end



  end
end

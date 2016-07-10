#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.join( File.dirname(__FILE__), 'helper' )
require File.join( File.dirname(__FILE__), 'performance_data' )


module Vz

  # Represents the Memory load.
  #
  # This can be related to a specific VE or to the hardware node
  # in general.
  #
  class Memory
    include Vz::Helper::ActiveVz

    LIMIT_COUNTER   = 'counter_memory_limit'
    USED_COUNTER    = 'counter_memory_used'

    def has_stats?
      !@document.nil?
    end

    def limit
      Vz::Stats.new(
        :document => REXML::XPath.first( self.counters.find { |c| REXML::XPath.first( c, './*[local-name()="name"]' ).text == LIMIT_COUNTER }, './*[local-name()="value"]' )
      )
    end

    def used
      Vz::Stats.new(
        :document => REXML::XPath.first( self.counters.find { |c| REXML::XPath.first( c, './*[local-name()="name"]' ).text == USED_COUNTER }, './*[local-name()="value"]' )
      )
    end

    def counters
      @document.get_elements('./*/*[local-name()="counter"]')
    end

    def utilization_as_percentage
      return 0 unless ( has_stats? && self.limit.current.to_f > 0.0 )

      puts "used: #{self.used.current}"
      puts "limit: #{self.limit.current}"
      # puts "calc: #{(( self.used.current.to_f / self.limit.current.to_f ) * 100).to_i}"

      (( self.used.current.to_f / self.limit.current.to_f ) * 100).to_i
    end

  end
end

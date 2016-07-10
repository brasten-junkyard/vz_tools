#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.join( File.dirname(__FILE__), 'helper', 'active_vz' )
require 'vz/helper'
require 'vz/resource_locator'

module Vz

  # Represents the CPU load.
  #
  # This can be related to a specific VE or to the hardware node
  # in general.
  #
  class CpuLoad
    include Vz::Helper::ActiveVz

    attr_remote :system
    attr_remote :user
    attr_remote :nice
    attr_remote :idle

    SYSTEM_COUNTER    = 'counter_cpu_system_states'
    USER_COUNTER      = 'counter_cpu_user_states'
    NICE_COUNTER      = 'counter_cpu_nice_states'
    IDLE_COUNTER      = 'counter_cpu_idle_states'

    def has_stats?
      !@document.nil?
    end

    def system
      Vz::Stats.new( :document => self.counters.find { |c| c.get_elements('./*[local-name()="name"]').first.text == SYSTEM_COUNTER }.get_elements('./*[local-name()="value"]').first )
    end

    def user
      Vz::Stats.new( :document => self.counters.find { |c| c.get_elements('./*[local-name()="name"]').first.text == USER_COUNTER }.get_elements('./*[local-name()="value"]').first )
    end

    def nice
      Vz::Stats.new( :document => self.counters.find { |c| c.get_elements('./*[local-name()="name"]').first.text == NICE_COUNTER }.get_elements('./*[local-name()="value"]').first )
    end

    def idle
      Vz::Stats.new( :document => self.counters.find { |c| c.get_elements('./*[local-name()="name"]').first.text == IDLE_COUNTER }.get_elements('./*[local-name()="value"]').first )
    end

    def counters
      @document.get_elements('./*/*[local-name()="counter"]')
    end

    def utilization_as_percentage
      puts "CPU IDLE: #{self.idle.document.to_s}"

      ( 100 - self.idle.current )
    end

  end
end

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
  class NetLoad
    include Vz::Helper::ActiveVz

    attr_remote :no_stats
    attr_remote :system
    attr_remote :user
    attr_remote :nice
    attr_remote :idle


    def has_stats?
      !(self.no_stats == true)
    end

  end
end

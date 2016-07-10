#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'

module Vz

  # CpuInfo provides informational data about the hardware
  # node's CPU.
  #
  class CpuInfo
    include ValueObject

    attr_reader :mhz
    attr_reader :name
    attr_reader :number
    attr_reader :cores
    attr_reader :hyperthreads
    attr_reader :units
    attr_reader :family
    attr_reader :model
    attr_reader :bogomips

  end
end

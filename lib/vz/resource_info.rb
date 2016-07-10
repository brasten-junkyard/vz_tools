#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/helper/active_vz'

module Vz
  class ResourceInfo
    MEMORY_COUNTERS = 'counters_vz_memory'
    CPU_COUNTERS    = 'counters_vz_cpu'

    def initialize( source )
      @source =
        source.map do |src|
          src.kind_of?(Vz::PerformanceData) ? src : Vz::PerformanceData.new( :document => src )
        end
    end

    def performance_data_for( eid )
      Vz::PerformanceData.new( :document => @source.find { |s| s.eid == eid }.document )
    end

  end
end

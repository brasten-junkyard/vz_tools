#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.join( File.dirname(__FILE__), 'memory' )

module Vz
  class PerformanceData
    include Vz::Helper::ActiveVz

    def has_stats?
      !@document.nil?
    end

    def eid
      REXML::XPath.first( @document, './*[local-name()="eid"]' ).text
    end

    def name
      REXML::XPath.first( @document, './*[local-name()="class"]/*[local-name()="name"]' ).text
    end

    def memory_load
      mem = @document.get_elements('./*[local-name()="class"]').find { |f| REXML::XPath.first( f, './*[local-name()="name"]' ).text == Vz::ResourceInfo::MEMORY_COUNTERS }

      Vz::Memory.new(
        :document => mem
      )
    end

    def cpu_load
      cpu = @document.get_elements('./*[local-name()="class"]').find { |f| REXML::XPath.first( f, './*[local-name()="name"]' ).text == Vz::ResourceInfo::CPU_COUNTERS }

      Vz::CpuLoad.new(
        :document => cpu
      )
    end

    def counters
      @document.get_elements('./*[local-name()="class"]/*[local-name()="instance"]/*[local-name()="counter"]').map do |counter|
        Vz::PerformanceData::Counter.new( :document => counter )
      end
    end

  end

  class PerformanceData
    class Counter
      include Vz::Helper::ActiveVz

      def name
        @document.get_elements('./*[local-name()="name"]').text
      end

    end
  end

end

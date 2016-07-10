#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/qos'

module Vz

  # Represents standard statistics
  #
  # Attributes:
  #   - average
  #   - minimum
  #   - maximum
  #   - current_value
  #
  # Usage:
  #
  #   # you'll probably never create one, but if you did...
  #   stats = Stats.new( :average => 50, :minimum => 25, :maximum => 75 )
  #
  #   # more likely...
  #   puts obj_with_stats.some_stats.average
  #
  class Stats < Qos

    def maximum
      REXML::XPath.first( @document, './*[local-name()="max"]' ).text.to_i
    end

    def minimum
      REXML::XPath.first( @document, './*[local-name()="min"]' ).text.to_i
    end

    def total
      REXML::XPath.first( @document, './*[local-name()="total"]' ).text.to_i
    end

    def average
      REXML::XPath.first( @document, './*[local-name()="avg"]' ).text.to_i
    end

  end

end

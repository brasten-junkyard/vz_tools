#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'

module Vz

  # Load average type provides standard load-average data.
  #
  # Attributes contain VZTools::Api::Type::Stats instances.
  #
  class LoadAverage
    include ValueObject

    attr_reader :one_minute         # Stats
    attr_reader :five_minutes       # Stats
    attr_reader :fifteen_minutes    # Stats

  end
end

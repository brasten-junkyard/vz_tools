#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'

module Vz

  # Event
  #
  # The Event object represents actions or events being generated on
  # OpenVZ, usually without any associated requested action.  The most
  # common event is probably an Alert.
  #
  class Event
    include ValueObject

    attr_reader :id             # Universally-unique message id
    attr_reader :veid
    attr_reader :created_at
    attr_reader :source
    attr_reader :category
    attr_reader :security_id
    attr_reader :count
    attr_reader :data
    attr_reader :info           # Event description
    attr_reader :event_data     # One of EventData subclasses

  end
end

#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Support
    class DateConversion

      def self.to_date( str )
        DateTime.parse(str)
      end

      def self.from_date( datetime )
        datetime.strftime('%Y-%m-%dT%H:%M:%S%z')
      end

    end
  end
end

#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

class ConnectorError < StandardError

  class << self

    def for( code )
      case code
      when -17
        NoDataAvailableError
      else
        ConnectorError
      end
    end

  end

end

class NoDataAvailableError < StandardError; end

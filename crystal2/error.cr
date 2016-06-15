module Mal extend self
  class ParseException < Exception
  end

  def parse_error(msg)
    raise ParseException.new msg
  end
end

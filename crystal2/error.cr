module Mal extend self
  class ParseException < Exception
  end

  class EvalException < Exception
  end

  def parse_error(msg)
    raise ParseException.new msg
  end

  def eval_error(msg)
    raise EvalException.new msg
  end
end

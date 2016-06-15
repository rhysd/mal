require "./expr"

module Mal extend self
  def pr_str(value, print_readably = true)
    case value
    when Nil          then "nil"
    when Bool         then value.to_s
    when Int32        then value.to_s
    when List    then "(#{value.map{|v| pr_str(v, print_readably) as String}.join(" ")})"
    when Vector  then "[#{value.map{|v| pr_str(v, print_readably) as String}.join(" ")}]"
    when Symbol  then value as String
    when Func    then "<function>"
    when HashMap
      # step1_read_print.cr requires specifying type
      "{#{value.map{|k, v| "#{pr_str(k, print_readably)} #{pr_str(v, print_readably)}" as String}.join(" ")}}"
    when String
      case
      when value.empty?()
        print_readably ? value.inspect : value
      when value[0] == '\u029e'
        ":#{value[1..-1]}"
      else
        print_readably ? value.inspect : value
      end
    else
      raise "invalid MalType: #{value.to_s}"
    end
  end
end

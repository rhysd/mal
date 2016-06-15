require "./error"
require "./expr"

module Mal
  RE_TOKENIZE = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/

  def tokenize(code)
    code.scan(RE_TOKENIZE).map{|m| m[1]}.reject(&.empty?)
  end

  class Parser
    def initialize(@tokens : Array(String))
      @pos = 0
    end

    def peek
      t = @tokens[@pos]?
      if t && t[0] == ';'
        @pos += 1
        peek
      else
        t
      end
    end

    def eat
      peek
    ensure
      @pos += 1
    end

    def parse_delim(init, open, close) : Expr
      token = eat
      Mal.parse_error "expected '#{open}', got EOF" unless token
      Mal.parse_error "expected '#{open}', got #{token}" unless token[0] == open

      loop do
        token = peek
        Mal.parse_error "expected '#{close}', got EOF" unless token
        break if token[0] == close

        init << parse_expr
        peek
      end

      eat
      init
    end

    def parse_list : Expr
      parse_delim(List.new, '(', ')')
    end

    def parse_vector : Expr
      parse_delim(Vector.new, '[', ']')
    end

    def parse_hashmap : Expr
      exprs = parse_delim([] of Expr, '{', '}')

      Mal.parse_error "odd number of elements for hash-map: #{exprs.size}" if exprs.size.odd?
      map = HashMap.new

      exprs.each_slice(2) do |kv|
        k, v = kv
        if k.is_a? String
          map[k] = v
        else
          Mal.parse_error("key of hash-map must be string or keyword")
        end
      end

      map
    end

    def parse_atom : Expr
      token = eat
      Mal.parse_error "expected Atom but got EOF" unless token

      case
      when token =~ /^-?\d+$/ then token.to_i
      when token == "true"    then true
      when token == "false"   then false
      when token == "nil"     then nil
      when token[0] == '"'    then token[1..-2].gsub(/\\"/, "\"")
                                               .gsub(/\\n/, "\n")
                                               .gsub(/\\\\/, "\\")
      when token[0] == ':'    then "\u029e#{token[1..-1]}"
      else                         token as Symbol
      end
    end

    def parse_expr : Expr
      token = peek

      Mal.parse_error "unexpected EOF" unless token
      Mal.parse_error "unexpected comment" if token[0] == ';'

      case token
      when "("  then parse_list
      when ")"  then Mal.parse_error "unexpected ')'"
      when "["  then parse_vector
      when "]"  then Mal.parse_error "unexpected ']'"
      when "{"  then parse_hashmap
      when "}"  then Mal.parse_error "unexpected '}'"
      when "'"  then eat; List.new << "quote" << parse_expr
      when "`"  then eat; List.new << "quasiquote" << parse_expr
      when "~"  then eat; List.new << "unquote" << parse_expr
      when "~@" then eat; List.new << "splice-unquote" << parse_expr
      when "@"  then eat; List.new << "deref" << parse_expr
      when "^"  then eat; List.new << "with-meta" << parse_expr << parse_expr
      else           parse_atom
      end
    end
  end

  def parse(str)
    p = Parser.new(tokenize(str))
    begin
      p.parse_expr
    ensure
      raise "expected EOF but got #{p.peek.to_s}" unless p.peek.nil?
    end
  end
end

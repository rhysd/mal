require "./readline"
require "./parser"
require "./print"
require "./error"
require "./expr"

# Note:
# Employed downcase names because Crystal prohibits uppercase names for methods

module Mal

  def read(str)
    parse str
  end

  def eval(ast : Expr, env) : Expr
    case ast
    when Array
      return ast if ast.empty?

      e = ast.first
      case e
      when Symbol
        ast[0] = eval(e, env)
        eval(ast, env)
      when Func
        ast.shift 1
        e.call(ast.map{|e| eval(e, env) as Expr})
      else
        ast.map{|e| eval(e, env) as Expr}
      end
    when HashMap
      ast.each{|k, v| ast[k] = eval(v, env)}
    when Symbol
      if env.has_key? ast
        env[ast]
      else
        eval_error "'#{ast}' not found"
      end
    else
      ast
    end
  end

  def print(expr)
    pr_str expr
  end

  def rep(str, env)
    print(eval(read(str), env))
  end

  macro numeric_op(op)
    -> (args : Array(Expr)) {
      x, y = args[0], args[1]
      eval_error "invalid argument: must be number for numeric operators" unless x.is_a?(Int32) && y.is_a?(Int32)
      (x {{op.id}} y) as Expr
    } as Func
  end

  $repl_env = {
    "+" => numeric_op(:+),
    "-" => numeric_op(:-),
    "*" => numeric_op(:*),
    "/" => numeric_op(:/),
  } of String => Func
end

while line = Mal.readline("user> ")
  begin
    puts Mal.rep(line, $repl_env)
  rescue e
    STDERR.puts e
  end
end

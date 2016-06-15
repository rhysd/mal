require "./readline"
require "./parser"
require "./print"

# Note:
# Employed downcase names because Crystal prohibits uppercase names for methods

def read(str)
  Mal.parse str
end

def eval(x)
  x
end

def print(expr)
  Mal.pr_str expr
end

def rep(str)
  read(eval(print(str)))
end

while line = Mal.readline("user> ")
  puts rep(line)
end

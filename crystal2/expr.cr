module Mal
  alias Symbol = String
  alias Expr = Nil | Bool | Int32 | String | Symbol | List | Vector | HashMap | Func
  alias Func = (Array(Expr) -> Expr)
  alias Vector = Array(Expr)
  alias List = Array(Expr)
  alias HashMap = Hash(String, Expr)
end

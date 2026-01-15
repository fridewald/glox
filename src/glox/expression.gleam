import gleam/float
import gleam/io
import glox/token.{type Token}

pub type Expression {
  Literal(Literal)
  Unary(operator: Token, right: Expression)
  Binary(operator: Token, left: Expression, right: Expression)
  Grouping(Expression)
}

pub type Literal {
  Number(Float)
  String(String)
  True
  False
  Nil
}

// Todo: should we use a string builder?
//
// > The BEAM virtual machine has an optimisation for appending strings, where it
// > will mutate the string buffer when safe to do so, so if you are looking to
// > build a string through appending many small strings then you may get better
// > performance by not using a string tree. Always benchmark your performance
// > sensitive code.
pub fn print_ast(expression: Expression) {
  let expression_string = experssion_to_string(expression)
  io.println(expression_string)
}

pub fn experssion_to_string(expression) {
  case expression {
    Literal(literal) -> print_literal(literal)
    Unary(operator:, right:) ->
      parenthesize(
        token.token_type_to_lexeme(operator.token_type)
        <> " "
        <> experssion_to_string(right),
      )
    Binary(operator:, left:, right:) ->
      parenthesize(
        token.token_type_to_lexeme(operator.token_type)
        <> " "
        <> experssion_to_string(left)
        <> " "
        <> experssion_to_string(right),
      )
    Grouping(exp) -> parenthesize("group " <> experssion_to_string(exp))
  }
}

fn parenthesize(string: String) -> String {
  "(" <> string <> ")"
}

fn print_literal(literal: Literal) -> String {
  case literal {
    Number(num) -> num |> float.to_string()
    String(str) -> str
    True -> "true"
    False -> "false"
    Nil -> "nil"
  }
}

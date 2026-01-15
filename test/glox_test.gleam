import gleeunit
import glox/expression
import glox/token.{Token}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn expression_to_string_test() {
  let expression =
    expression.Binary(
      token.Token(token.Star, "*", 1),
      expression.Unary(
        Token(token.Minus, "-", 1),
        expression.Literal(expression.Number(123.0)),
      ),
      expression.Grouping(expression.Literal(expression.Number(45.67))),
    )

  assert "(* (- 123.0) (group 45.67))"
    == expression.experssion_to_string(expression)
}

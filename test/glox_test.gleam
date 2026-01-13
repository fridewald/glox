import gleam/result
import gleeunit
import glox/scanner
import glox/token.{Token}

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn all_single_keyword_test() {
  let all_single_keywords = "(){},.-+;*/"

  let tokens = scanner.scan_tokens(all_single_keywords)

  assert result.is_ok(tokens) == True
}

pub fn single_keyword_test() {
  let single_keyword = "*"

  let tokens = scanner.scan_tokens(single_keyword)

  assert tokens == Ok([Token(token.Star, "*", 1), Token(token.Eof, "", 1)])
}

pub fn unsupported_keyword_test() {
  let unsupported_keyword = "["

  let tokens = scanner.scan_tokens(unsupported_keyword)

  assert tokens == Error([token.TokenError(token.UnsupportedCharacter("["), 1)])
}

pub fn operator_keyword_test() {
  let operators = "=.!="

  let tokens = scanner.scan_tokens(operators)

  assert tokens
    == Ok([
      Token(token.Equal, "=", 1),
      Token(token.Dot, ".", 1),
      Token(token.BangEqual, "!=", 1),
      Token(token.Eof, "", 1),
    ])
}

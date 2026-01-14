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

pub fn ignore_whitespaces_test() {
  let white_spaces = "==\n/\t +\n"

  let tokens = scanner.scan_tokens(white_spaces)

  assert tokens
    == Ok([
      Token(token.EqualEqual, "==", 1),
      Token(token.Slash, "/", 2),
      Token(token.Plus, "+", 2),
      Token(token.Eof, "", 3),
    ])
}

pub fn ignore_comment_test() {
  let with_comment = "// This is a comment\n()"

  let tokens = scanner.scan_tokens(with_comment)

  assert tokens
    == Ok([
      Token(token.LeftParen, "(", 2),
      Token(token.RightParen, ")", 2),
      Token(token.Eof, "", 2),
    ])
}

pub fn string_test() {
  let with_string = "\"Hallo Lucy!\"\"*\n*\n*\""

  let tokens = scanner.scan_tokens(with_string)

  assert tokens
    == Ok([
      Token(token.String("Hallo Lucy!"), "\"Hallo Lucy!\"", 1),
      Token(token.String("*\n*\n*"), "\"*\n*\n*\"", 1),
      Token(token.Eof, "", 3),
    ])
}

pub fn unclosed_string_test() {
  let with_string = "\"Hallo Tilda\n\n"

  let tokens = scanner.scan_tokens(with_string)

  assert tokens
    == Error([
      token.TokenError(token.UnterminatedString, 1),
    ])
}

pub fn number_test() {
  let number_lex = "123\n456.7809"

  let tokens = scanner.scan_tokens(number_lex)

  assert tokens
    == Ok([
      Token(token.Number(123.0), "123", 1),
      Token(token.Number(456.7809), "456.7809", 2),
      Token(token.Eof, "", 2),
    ])
}

pub fn unsupported_number_test() {
  let number_lex = "123.\n"
  // TODO: don't allow leading dot
  // let number_lex = "123.\n.78"

  let tokens = scanner.scan_tokens(number_lex)

  assert tokens
    == Error([
      token.TokenError(token.ParseError, 1),
    ])
}

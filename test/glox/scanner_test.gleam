import gleam/result
import glox/scanner
import glox/token.{Token}

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

pub fn identifier_test() {
  let identifier_lex =
    "and class else false fun for if nil or print return super this true var while"
  let tokens = scanner.scan_tokens(identifier_lex)

  assert tokens
    == Ok([
      Token(token.And, "and", 1),
      Token(token.Class, "class", 1),
      Token(token.Else, "else", 1),
      Token(token.False, "false", 1),
      Token(token.Fun, "fun", 1),
      Token(token.For, "for", 1),
      Token(token.If, "if", 1),
      Token(token.Nil, "nil", 1),
      Token(token.Or, "or", 1),
      Token(token.Print, "print", 1),
      Token(token.Return, "return", 1),
      Token(token.Super, "super", 1),
      Token(token.This, "this", 1),
      Token(token.True, "true", 1),
      Token(token.Var, "var", 1),
      Token(token.While, "while", 1),
      Token(token.Eof, "", 1),
    ])
}

pub fn reserved_keyword_test() {
  let reserved_keyword_lex = "var Test = \"10\""

  let tokens = scanner.scan_tokens(reserved_keyword_lex)

  assert tokens
    == Ok([
      Token(token.Var, "var", 1),
      Token(token.Identifier("Test"), "Test", 1),
      Token(token.Equal, "=", 1),
      Token(token.String("10"), "\"10\"", 1),
      Token(token.Eof, "", 1),
    ])
}

pub fn unsupported_identifier_todo() {
  let unsupported_identifier = "var 1ten"

  let tokens = scanner.scan_tokens(unsupported_identifier)

  assert tokens
    == Error([
      token.TokenError(token.ParseError, 1),
    ])
}

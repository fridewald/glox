import gleam/bool
import gleam/list
import glox/token.{type Token}

pub type Source {
  Source(input: String, line: Int)
}

pub fn scan_tokens(source: String) -> Result(List(Token), String) {
  do_scan_tokens(Source(source, 1), [])
}

fn do_scan_tokens(
  source: Source,
  result: List(Token),
) -> Result(List(Token), String) {
  use <- bool.guard(source.input == "", finish_scanning(result, source.line))

  let #(curr_result, new_input) = case source.input {
    "(" <> rest -> #(token.Token(token.LeftParen, "(", "", source.line), rest)
    ")" <> rest -> #(token.Token(token.RightParen, ")", "", source.line), rest)
    "{" <> rest -> #(token.Token(token.LeftBrace, "{", "", source.line), rest)
    "}" <> rest -> #(token.Token(token.RightBrace, "}", "", source.line), rest)
    "," <> rest -> #(token.Token(token.Comma, ",", "", source.line), rest)
    "." <> rest -> #(token.Token(token.Dot, ".", "", source.line), rest)
    "-" <> rest -> #(token.Token(token.Minus, "-", "", source.line), rest)
    "+" <> rest -> #(token.Token(token.Plus, "+", "", source.line), rest)
    ";" <> rest -> #(token.Token(token.Semicolon, ";", "", source.line), rest)
    "*" <> rest -> #(token.Token(token.Star, "*", "", source.line), rest)
    "/" <> rest -> #(token.Token(token.Slash, "/", "", source.line), rest)
    _ -> todo
  }
  let new_source = Source(new_input, source.line)
  do_scan_tokens(new_source, [curr_result, ..result])
}

fn finish_scanning(
  result: List(Token),
  line: Int,
) -> Result(List(Token), String) {
  let result = [token.Token(token.Eof, "", "", line), ..result]
  list.reverse(result)
  |> Ok
}

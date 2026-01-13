import gleam/list
import gleam/string
import glox/token.{type Token, type TokenError, EmptyString, TokenError}

pub type Source {
  Source(input: String, line: Int)
}

type Match {
  Match(token: Token, next_source: Source)
  NoMatch
  MatchError(error: TokenError, next_source: Source)
}

pub fn scan_tokens(source: String) -> Result(List(Token), List(TokenError)) {
  do_scan_tokens(Source(source, 1), [])
  |> scan_collect_result
}

fn scan_collect_result(
  results: List(Result(Token, TokenError)),
) -> Result(List(Token), List(TokenError)) {
  // via this fold the results are reversed, so we reverse the list first
  list.fold(results |> list.reverse, Ok([]), fn(acc, next) {
    case acc, next {
      Ok(res), Ok(next_res) -> Ok([next_res, ..res])
      Ok(_), Error(first) -> Error([first])
      Error(_), Ok(_) -> acc
      Error(err), Error(next_error) -> Error([next_error, ..err])
    }
  })
}

fn do_scan_tokens(
  source: Source,
  results: List(Result(Token, TokenError)),
) -> List(Result(Token, TokenError)) {
  let #(token_result, next_source) = match(source)

  let next_results = [token_result, ..results]
  case token_result {
    // recursion end
    Ok(token) if token.token_type == token.Eof -> list.reverse(next_results)
    Error(TokenError(EmptyString, _)) -> list.reverse(next_results)
    _ -> {
      do_scan_tokens(next_source, next_results)
    }
  }
}

fn match(source: Source) -> #(Result(Token, TokenError), Source) {
  use <- match_guard(test_match: match_eof(source))
  use <- match_guard(test_match: match_single_character_token(source))
  use <- match_guard(test_match: match_operator(source))
  // use <- match_guard(test_match: match_comment(source))
  // // use <- match_guard(test_match: ignore_white_spaces(source))
  // use <- match_guard(test_match: match_string_literal(source))
  // use <- match_guard(test_match: match_number_literal(source))
  // use <- match_guard(test_match: match_identifiers(source))
  // use <- match_guard(test_match: match_reserved_word(source))
  case string.pop_grapheme(source.input) {
    Ok(#(char, rest)) -> #(
      Error(TokenError(token.UnsupportedCharacter(char), source.line)),
      Source(input: rest, line: source.line),
    )
    Error(_) -> #(Error(TokenError(EmptyString, source.line)), source)
  }
}

/// try to match
fn match_guard(
  test_match match_result: Match,
  continue fun: fn() -> #(Result(Token, TokenError), Source),
) -> #(Result(Token, TokenError), Source) {
  case match_result {
    Match(token:, next_source:) -> #(Ok(token), next_source)
    NoMatch -> fun()
    MatchError(error:, next_source:) -> #(Error(error), next_source)
  }
}

fn match_eof(source: Source) -> Match {
  case source.input == "" {
    True -> Match(token.Token(token.Eof, "", source.line), source)
    False -> NoMatch
  }
}

fn match_single_character_token(source: Source) -> Match {
  case source.input {
    "(" <> rest -> ok_match(token.LeftParen, source, rest)
    ")" <> rest -> ok_match(token.RightParen, source, rest)
    "{" <> rest -> ok_match(token.LeftBrace, source, rest)
    "}" <> rest -> ok_match(token.RightBrace, source, rest)
    "," <> rest -> ok_match(token.Comma, source, rest)
    "." <> rest -> ok_match(token.Dot, source, rest)
    "-" <> rest -> ok_match(token.Minus, source, rest)
    "+" <> rest -> ok_match(token.Plus, source, rest)
    ";" <> rest -> ok_match(token.Semicolon, source, rest)
    "*" <> rest -> ok_match(token.Star, source, rest)
    "/" <> rest -> ok_match(token.Slash, source, rest)
    _unsupported -> no_match(source)
  }
}

fn match_operator(source: Source) -> Match {
  case source.input {
    "!=" <> rest -> ok_match(token.BangEqual, source, rest)
    "!" <> rest -> ok_match(token.Bang, source, rest)
    "<=" <> rest -> ok_match(token.LessEqual, source, rest)
    "<" <> rest -> ok_match(token.Less, source, rest)
    ">=" <> rest -> ok_match(token.GreaterEqual, source, rest)
    ">" <> rest -> ok_match(token.Greater, source, rest)
    "==" <> rest -> ok_match(token.EqualEqual, source, rest)
    "=" <> rest -> ok_match(token.Equal, source, rest)
    _unsupported -> no_match(source)
  }
}

fn no_match(source: Source) -> Match {
  case string.pop_grapheme(source.input) {
    Ok(_) -> NoMatch
    Error(_) -> MatchError(TokenError(EmptyString, source.line), source)
  }
}

fn ok_match(token_type: token.TokenType, source: Source, rest: String) -> Match {
  Match(
    token.Token(
      token_type: token_type,
      lexeme: token.token_type_to_lexeme(token_type),
      line: source.line,
    ),
    Source(rest, source.line),
  )
}

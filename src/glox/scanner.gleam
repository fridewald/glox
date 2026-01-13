import gleam/list
import gleam/result
import gleam/string
import glox/token.{
  type Token, type TokenError, NotSingleCharacter, ParseError, TokenError,
  UnsupportedCharacter,
}

pub type Source {
  Source(input: String, line: Int)
}

type Match {
  Match(token: Token, next_source: Source)
  NoMatch
}

type MatchError {
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
    Error(TokenError(token.EmptyString, _)) -> list.reverse(next_results)
    _ -> {
      do_scan_tokens(next_source, next_results)
    }
  }
}

fn match(source: Source) -> #(Result(Token, TokenError), Source) {
  use <- match_guard(test_match: match_eof(source))
  use <- match_guard(test_match: match_single_character_token(source))
  case string.pop_grapheme(source.input) {
    Ok(#(char, rest)) -> #(
      Error(TokenError(token.UnsupportedCharacter(char), source.line)),
      Source(input: rest, line: source.line),
    )
    Error(_) -> #(Error(TokenError(token.EmptyString, source.line)), source)
  }
}

/// try to match
fn match_guard(
  test_match match_result: Result(Match, MatchError),
  continue fun: fn() -> #(Result(Token, TokenError), Source),
) -> #(Result(Token, TokenError), Source) {
  case match_result {
    Ok(Match(token:, next_source:)) -> #(Ok(token), next_source)
    Ok(NoMatch) -> fun()
    Error(MatchError(error:, next_source:)) -> #(Error(error), next_source)
  }
}

fn match_eof(source: Source) -> Result(Match, MatchError) {
  case source.input == "" {
    True -> Ok(Match(token.Token(token.Eof, "", source.line), source))
    False -> Ok(NoMatch)
  }
}

fn match_single_character_token(source: Source) -> Result(Match, MatchError) {
  use #(char, rest) <- result.try(
    string.pop_grapheme(source.input)
    |> result.replace_error(MatchError(
      TokenError(ParseError, source.line),
      source,
    )),
  )
  case token.parse_single_character_token_from_string(char) {
    Ok(token) ->
      Ok(Match(
        token.Token(token_type: token, lexeme: char, line: source.line),
        Source(rest, source.line),
      ))
    Error(ParseError) ->
      Error(MatchError(
        TokenError(ParseError, source.line),
        Source(..source, input: rest),
      ))
    Error(UnsupportedCharacter(_))
    | Error(NotSingleCharacter)
    | Error(token.EmptyString) -> Ok(NoMatch)
  }
}

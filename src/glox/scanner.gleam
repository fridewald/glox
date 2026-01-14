import gleam/bool
import gleam/float
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import glox/token.{type Token, type TokenError, EmptyString, TokenError}
import splitter.{type Splitter}

pub type Source {
  Source(input: String, line: Int)
}

type Match {
  Match(token: Token, next_source: Source)
  Continue(next_source: Source)
  Ignore(next_source: Source)
  MatchError(error: TokenError, next_source: Source)
}

type Matcher {
  Mather(match: fn(Source) -> #(Result(Token, TokenError), Source))
}

pub fn scan_tokens(source: String) -> Result(List(Token), List(TokenError)) {
  let matcher = Mather(match())
  do_scan_tokens(Source(source, 1), matcher, [])
  |> scan_collect_result
}

fn scan_collect_result(
  results: List(Result(Token, TokenError)),
) -> Result(List(Token), List(TokenError)) {
  // via this fold the results are reversed, so we reverse the list first
  list.fold(results |> list.reverse, Ok([]), fn(acc, next) {
    case acc, next {
      // filter out ignore token
      Ok(res), Ok(token.Token(token.Ignore, _, _)) -> Ok(res)
      // add next token
      Ok(res), Ok(next_res) -> Ok([next_res, ..res])
      // convert to error
      Ok(_), Error(first) -> Error([first])
      // ignore token as we already have an error
      Error(_), Ok(_) -> acc
      // add error
      Error(err), Error(next_error) -> Error([next_error, ..err])
    }
  })
}

fn do_scan_tokens(
  source: Source,
  matcher: Matcher,
  results: List(Result(Token, TokenError)),
) -> List(Result(Token, TokenError)) {
  let #(token_result, next_source) = matcher.match(source)

  let next_results = [token_result, ..results]
  case token_result {
    // recursion end
    Ok(token) if token.token_type == token.Eof -> list.reverse(next_results)
    Error(TokenError(EmptyString, _)) -> list.reverse(next_results)
    _ -> {
      do_scan_tokens(next_source, matcher, next_results)
    }
  }
}

fn match() -> fn(Source) -> #(Result(Token, TokenError), Source) {
  // cache splitters
  let line_ends_splitter = splitter.new(["\n"])
  let quotes_splitter = splitter.new(["\""])

  // match function
  fn(source: Source) -> #(Result(Token, TokenError), Source) {
    use source <- match_guard(test_match: match_eof(source))
    use source <- match_guard(test_match: match_single_character_token(source))
    use source <- match_guard(test_match: match_operator(source))
    use source <- match_guard(test_match: match_whitespaces(source))
    use source <- match_guard(test_match: match_slash_or_comment(
      source,
      line_ends_splitter,
    ))
    use source <- match_guard(test_match: match_string_literal(
      source,
      quotes_splitter,
    ))
    use source <- match_guard(test_match: match_number_literal(source))
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
}

fn match_guard(
  test_match match_result: Match,
  continue fun: fn(Source) -> #(Result(Token, TokenError), Source),
) -> #(Result(Token, TokenError), Source) {
  case match_result {
    Match(token:, next_source:) -> #(Ok(token), next_source)
    MatchError(error:, next_source:) -> #(Error(error), next_source)
    Ignore(next_source:) -> #(
      Ok(token.Token(token.Ignore, "", -1)),
      next_source,
    )
    Continue(source) -> fun(source)
  }
}

fn match_eof(source: Source) -> Match {
  case source.input == "" {
    True -> Match(token.Token(token.Eof, "", source.line), source)
    False -> Continue(source)
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
    _unsupported -> continue(source)
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
    _unsupported -> continue(source)
  }
}

fn match_whitespaces(source: Source) -> Match {
  case source.input {
    " " <> rest -> ignore(source, rest)
    "\r" <> rest -> ignore(source, rest)
    "\t" <> rest -> ignore(source, rest)
    "\n" <> rest -> ignore(Source(..source, line: source.line + 1), rest)
    _unsupported -> continue(source)
  }
}

fn match_slash_or_comment(source: Source, line_ends: Splitter) -> Match {
  case source.input {
    "//" <> _rest -> ignore_till_eol(source, line_ends)
    "/" <> rest -> ok_match(token.Slash, source, rest)
    _unsupported -> continue(source)
  }
}

fn match_string_literal(source: Source, quotes_splitter: Splitter) -> Match {
  case source.input {
    "\"" <> rest -> {
      let #(value, quote, rest) = splitter.split(quotes_splitter, rest)
      let new_lines =
        string.to_graphemes(value)
        |> list.count(fn(grapheme) { grapheme == "\n" })
      let token_type = token.String(value)
      case quote {
        "\"" ->
          Match(
            token.Token(
              token_type:,
              lexeme: token.token_type_to_lexeme(token_type),
              line: source.line,
            ),
            Source(input: rest, line: source.line + new_lines),
          )
        _ ->
          MatchError(
            TokenError(token.UnterminatedString, source.line),
            Source(..source, input: rest),
          )
      }
    }
    _un -> continue(source)
  }
}

fn match_number_literal(source: Source) -> Match {
  {
    use #(char, _rest) <- result.map(string.pop_grapheme(source.input))
    use <- bool.guard(!is_number(char), Continue(source))
    case consume_number(source.input, [], False) {
      #(Ok(res), input) ->
        Match(
          token.Token(token.Number(res.0), res.1, source.line),
          Source(..source, input:),
        )
      #(Error(_), input) ->
        MatchError(
          TokenError(token.ParseError, source.line),
          Source(..source, input:),
        )
    }
  }
  |> result.unwrap(MatchError(TokenError(EmptyString, source.line), source))
}

fn consume_number(
  input: String,
  lookahead: List(String),
  has_dot: Bool,
) -> #(Result(#(Float, String), token.ErrorType), String) {
  case string.pop_grapheme(input) {
    Ok(#(char, rest)) -> {
      // base case
      use <- bool.lazy_guard(number_break(char), fn() {
        number_base_case(lookahead, has_dot, input)
      })
      consume_number(rest, [char, ..lookahead], has_dot || char == ".")
    }
    Error(_) -> number_base_case(lookahead, has_dot, input)
  }
}

fn number_base_case(lookahead, has_dot, input) {
  let string_representation =
    lookahead
    |> list.reverse()
    |> string.join("")
  let string_with_dot_representation = case has_dot {
    True -> string_representation
    False -> string_representation <> ".0"
  }
  string_with_dot_representation
  |> float.parse()
  |> result.map(pair.new(_, string_representation))
  |> result.replace_error(token.ParseError)
  |> pair.new(input)
}

fn number_break(char: String) -> Bool {
  !is_number(char) && char != "."
}

fn is_number(to_check) {
  "0" == to_check
  || "1" == to_check
  || "2" == to_check
  || "3" == to_check
  || "4" == to_check
  || "5" == to_check
  || "6" == to_check
  || "7" == to_check
  || "8" == to_check
  || "9" == to_check
}

fn continue(source: Source) -> Match {
  case string.pop_grapheme(source.input) {
    Ok(_) -> Continue(source)
    Error(_) -> MatchError(TokenError(EmptyString, source.line), source)
  }
}

fn ignore(source: Source, rest: String) -> Match {
  Ignore(Source(..source, input: rest))
}

fn ignore_till_eol(source: Source, line_ends: Splitter) -> Match {
  let #(_current_line, _separator, next_line) =
    splitter.split(line_ends, source.input)
  Ignore(Source(input: next_line, line: source.line + 1))
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

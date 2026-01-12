import gleam/float
import gleam/io
import gleam/string

pub type Error {
  UnsupportedCharacter(char: String)
  ParseError
  NotSingleCharacter
  Empty
}

pub fn pretty_print_error(error: Error) {
  let print_string = case error {
    UnsupportedCharacter(char:) -> "UnsupportedCharacter(" <> char <> ")"
    ParseError -> "ParseError"
    NotSingleCharacter -> "NotSingleCharacter"
    Empty -> "Empty"
  }
  io.println_error(print_string)
}

pub type Token {
  Token(token_type: TokenType, lexeme: String, line: Int)
}

pub fn print_token(token: Token) {
  io.println(
    token_type_to_name_of_type(token.token_type) <> " " <> token.lexeme,
  )
}

pub fn parse_single_character_token_from_string(
  input: String,
) -> Result(TokenType, Error) {
  case string.pop_grapheme(input) {
    Ok(#("(", "")) -> Ok(LeftParen)
    Ok(#(")", "")) -> Ok(RightParen)
    Ok(#("{", "")) -> Ok(LeftBrace)
    Ok(#("}", "")) -> Ok(RightBrace)
    Ok(#(",", "")) -> Ok(Comma)
    Ok(#(".", "")) -> Ok(Dot)
    Ok(#("-", "")) -> Ok(Minus)
    Ok(#("+", "")) -> Ok(Plus)
    Ok(#(";", "")) -> Ok(Semicolon)
    Ok(#("*", "")) -> Ok(Star)
    Ok(#("/", "")) -> Ok(Slash)
    Ok(#(char, "")) -> Error(UnsupportedCharacter(char))
    Error(_) -> Error(ParseError)
    Ok(#(_, _)) -> Error(NotSingleCharacter)
  }
}

pub type TokenType {
  // Single-character tokens.
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  Comma
  Dot
  Minus
  Plus
  Semicolon
  Slash
  Star
  // One or two character tokens.
  Bang
  BangEquaL
  Equal
  EqualEqual
  Greater
  GreaterEqual
  Less
  LessEqual
  // Literals.
  Identifier(String)
  String(String)
  Number(Float)
  // Keywords.
  And
  Class
  Else
  False
  Fun
  For
  If
  Nil
  Or
  Print
  Return
  Super
  This
  True
  Var
  While
  Eof
}

pub fn token_type_to_name_of_type(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "LeftParen"
    RightParen -> "RightParen"
    LeftBrace -> "LeftBrace"
    RightBrace -> "RightBrace"
    Comma -> "Comma"
    Dot -> "Dot"
    Minus -> "Minus"
    Plus -> "Plus"
    Semicolon -> "Semicolon"
    Slash -> "Slash"
    Star -> "Star"
    Bang -> "Bang"
    BangEquaL -> "BangEquaL"
    Equal -> "Equal"
    EqualEqual -> "EqualEqual"
    Greater -> "Greater"
    GreaterEqual -> "GreaterEqual"
    Less -> "Less"
    LessEqual -> "LessEqual"
    Identifier(val) -> "Identifier(" <> val <> ")"
    String(val) -> "String(" <> val <> ")"
    Number(val) -> "Number(" <> val |> float.to_string <> ")"
    And -> "And"
    Class -> "Class"
    Else -> "Else"
    False -> "False"
    Fun -> "Fun"
    For -> "For"
    If -> "If"
    Nil -> "Nil"
    Or -> "Or"
    Print -> "Print"
    Return -> "Return"
    Super -> "Super"
    This -> "This"
    True -> "True"
    Var -> "Var"
    While -> "While"
    Eof -> "Eof"
  }
}

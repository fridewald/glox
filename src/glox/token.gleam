import gleam/float
import gleam/int
import gleam/io

//############################ Token Errors ####################################
pub type TokenError {
  TokenError(error: ErrorType, line: Int)
}

pub type ErrorType {
  UnsupportedCharacter(char: String)
  ParseError
  NotSingleCharacter
  EmptyString
}

pub fn pretty_print_error(error: TokenError) {
  let TokenError(error, line) = error
  let print_string = error_type_to_string(error)
  report(line, "", print_string)
}

pub fn error_type_to_string(error: ErrorType) {
  case error {
    UnsupportedCharacter(char:) -> "UnsupportedCharacter(" <> char <> ")"
    ParseError -> "ParseError"
    NotSingleCharacter -> "NotSingleCharacter"
    EmptyString -> "EmptyString"
  }
}

fn report(line: Int, where: String, message: String) {
  io.println_error(
    "[line " <> int.to_string(line) <> "] " <> where <> ": " <> message,
  )
}

//############################ Token ###########################################

pub type Token {
  Token(token_type: TokenType, lexeme: String, line: Int)
}

pub fn print_token(token: Token) {
  io.println(
    token_type_to_name_of_type(token.token_type) <> " " <> token.lexeme,
  )
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
  BangEqual
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
  // Ignore
  Ignore
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
    BangEqual -> "BangEquaL"
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
    Ignore -> "Ignore"
  }
}

pub fn token_type_to_lexeme(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "("
    RightParen -> ")"
    LeftBrace -> "{"
    RightBrace -> "}"
    Comma -> ","
    Dot -> "."
    Minus -> "-"
    Plus -> "+"
    Semicolon -> ";"
    Slash -> "/"
    Star -> "*"
    Bang -> "!"
    BangEqual -> "!="
    Equal -> "="
    EqualEqual -> "=="
    Greater -> ">"
    GreaterEqual -> ">="
    Less -> "<"
    LessEqual -> "<="
    Identifier(name) -> name
    String(value) -> "\"" <> value <> "\""
    Number(number) -> number |> float.to_string
    And -> "and"
    Class -> "class"
    Else -> "else"
    False -> "false"
    Fun -> "fun"
    For -> "for"
    If -> "if"
    Nil -> "nil"
    Or -> "or"
    Print -> "print"
    Return -> "return"
    Super -> "super"
    This -> "this"
    True -> "true"
    Var -> "var"
    While -> "while"
    Eof -> ""
    Ignore -> ""
  }
}

import argv
import gleam/io
import gleam/list
import gleave
import glox/scanner
import glox/token
import input
import simplifile

const usage = "Usage: glox [script]"

pub fn main() -> Nil {
  let args = argv.load().arguments
  case args {
    [] -> run_prompt()
    [script] -> run_file(script)
    [_, ..] -> {
      io.println(usage)
    }
  }
}

fn run_file(script: String) -> Nil {
  case simplifile.read(from: script) {
    Ok(file_content_string) -> run(file_content_string)
    Error(error) -> {
      io.println(simplifile.describe_error(error))
    }
  }
}

fn run_prompt() -> Nil {
  case input.input(prompt: "> ") {
    Ok("exit") -> gleave.exit(0)
    Ok(input) -> {
      run(input)
    }
    Error(_) -> {
      io.println("Error with prompt")
    }
  }
  run_prompt()
}

fn run(file_content_string: String) -> Nil {
  io.println("Running code...")
  let tokens = scanner.scan_tokens(file_content_string)
  case tokens {
    Ok(tokens) -> list.each(tokens, fn(token) { echo token })
    Error(error) ->
      error
      |> list.each(token.pretty_print_error)
  }
}

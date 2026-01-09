import gleam/int
import gleam/io

pub fn error(line: Int, message: String) {
  report(line, "", message)
}

fn report(line: Int, where: String, message: String) {
  io.println_error(
    "[line " <> int.to_string(line) <> "] " <> where <> ": " <> message,
  )
}

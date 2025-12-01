import argv
import gleam/int
import gleam/io
import gleam/string
import simplifile
import solution

pub fn main() -> Nil {
  case argv.load().arguments {
    [path] -> io.println(int.to_string(solution.solve(read(path))))
    _ -> io.println_error("Usage: day01 <path>")
  }
}

fn read(path) -> List(String) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) -> string.split(data, "\n")
    _ -> panic as { "Failed to read file " <> path }
  }
}

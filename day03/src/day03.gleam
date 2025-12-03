import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile
import solution

pub fn main() -> Nil {
  case argv.load().arguments {
    [path] -> {
      let #(part1, part2) = solution.solve(read(path))
      io.println(int.to_string(part1))
      io.println(int.to_string(part2))
    }
    _ -> io.println_error("Usage: day01 <path>")
  }
}

fn read(path) -> List(solution.Battery) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) -> list.map(string.split(data, "\n"), digit_array)
    _ -> panic as { "Failed to read file " <> path }
  }
}

fn digit_array(str: String) -> List(Int) {
  case string.first(str) {
    Ok(chr) ->
      case int.parse(chr) {
        Ok(i) -> [i, ..digit_array(string.drop_start(str, 1))]
        Error(_) -> digit_array(string.drop_start(str, 1))
      }
    Error(_) -> []
  }
}

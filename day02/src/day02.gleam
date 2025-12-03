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

fn read(path) -> List(solution.Range) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) ->
      list.map(string.split(data, ","), fn(sr) {
        case string.split(sr, "-") {
          [lower, upper] ->
            case int.parse(lower), int.parse(upper) {
              Ok(l), Ok(u) -> #(l, u)
              _, _ ->
                panic as { "Failed to parse " <> lower <> " or " <> upper }
            }
          _ -> panic as { "Failed to parse range " <> sr }
        }
      })
    _ -> panic as { "Failed to read file " <> path }
  }
}

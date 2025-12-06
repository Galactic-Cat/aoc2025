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
      let #(ranges, ids) = read(path)
      let #(part1, part2) = solution.solve(ranges, ids)
      io.println(int.to_string(part1))
      io.println(int.to_string(part2))
    }
    _ -> io.println_error("Usage: day01 <path>")
  }
}

fn read(path) -> #(List(solution.Range), List(Int)) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) -> {
      case string.split(data, "\n\n") {
        [ranges_str, ids_str] -> #(read_ranges(ranges_str), read_ids(ids_str))
        _ -> panic as { "Failed to get ranges and ids" }
      }
    }
    _ -> panic as { "Failed to read file " <> path }
  }
}

fn read_ids(data: String) -> List(Int) {
  string.split(data, "\n")
  |> list.map(fn(id_str) {
    case int.parse(id_str) {
      Ok(id) -> id
      Error(_) -> panic as { "Failed to parse id " <> id_str }
    }
  })
}

fn read_ranges(data: String) -> List(solution.Range) {
  string.split(data, "\n")
  |> list.map(fn(range_str) {
    case string.split(range_str, "-") {
      [lower, upper] ->
        case int.parse(lower), int.parse(upper) {
          Ok(l), Ok(u) -> #(l, u)
          _, _ ->
            panic as { "Failed to parse either " <> lower <> " or " <> upper }
        }
      _ -> panic as { "Failed to parse range " <> range_str }
    }
  })
}

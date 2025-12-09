import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile
import solution.{type Coordinate}

pub fn main() -> Nil {
  case argv.load().arguments {
    [path] -> {
      let #(part1, _part2) = solution.solve(read(path))
      io.println(int.to_string(part1))
      // io.println(int.to_string(part2))
    }
    _ -> io.println_error("Usage: day01 <path>")
  }
}

fn read(path) -> List(Coordinate) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) -> {
      string.split(data, "\n")
      |> list.map(fn(line) {
        case string.split(line, ",") {
          [sx, sy, sz] ->
            case int.parse(sx), int.parse(sy), int.parse(sz) {
              Ok(x), Ok(y), Ok(z) -> #(x, y, z)
              _, _, _ -> panic as { "Failed to parse line (1) " <> line }
            }
          _ -> panic as { "Failed to parse line (2) " <> line }
        }
      })
    }
    _ -> panic as { "Failed to read file " <> path }
  }
}

import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import grid
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

fn read(path) -> grid.Grid(solution.Z) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) -> {
      string.split(data, "\n")
      |> list.map(to_z)
      |> grid.create()
    }
    _ -> panic as { "Failed to read file " <> path }
  }
}

fn to_z(line: String) -> List(solution.Z) {
  case string.first(line) {
    Ok("@") -> [solution.Roll, ..to_z(string.drop_start(line, 1))]
    Ok(".") -> [solution.Floor, ..to_z(string.drop_start(line, 1))]
    Ok(c) -> panic as { "Character '" <> c <> "' not recognized" }
    Error(_) -> []
  }
}

import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import grid.{type Grid}
import simplifile
import solution.{
  type Column, type Column2, Add, Add2, Empty2, Multiply, Multiply2, Number,
  Number2, Op,
}

pub fn main() -> Nil {
  case argv.load().arguments {
    [path] -> {
      io.println(int.to_string(solution.solve(read(path))))
      io.println(int.to_string(solution.solve2(read2(path))))
    }
    _ -> io.println_error("Usage: day01 <path>")
  }
}

fn read(path) -> Grid(Column) {
  io.println("Reading file " <> path)

  case simplifile.read(path) {
    Ok(data) -> {
      string.split(data, "\n")
      |> list.map(fn(line) {
        let assert Ok(rgx) = regexp.from_string("\\s+")
        regexp.split(rgx, string.trim(line))
      })
      |> grid.create()
      |> grid.map(fn(s) {
        case s {
          "+" -> Op(Add)
          "*" -> Op(Multiply)
          _ ->
            case int.parse(s) {
              Ok(n) -> Number(n)
              Error(_) -> panic as { "Failed to parse " <> s <> " to number" }
            }
        }
      })
    }
    _ -> panic as { "Failed to read file " <> path }
  }
}

fn read2(path) -> Grid(Column2) {
  io.println("Reading2 file " <> path)

  case simplifile.read(path) {
    Ok(data) ->
      {
        string.split(data, "\n")
        |> list.map(fn(line) { string.split(line, "") })
      }
      |> grid.create()
      |> grid.map(fn(s) {
        case s {
          " " -> Empty2
          "+" -> Add2
          "*" -> Multiply2
          _ ->
            case int.parse(s) {
              Ok(n) -> Number2(n)
              Error(_) -> panic as { "Failed to parse " <> s }
            }
        }
      })

    _ -> panic as { "Failed to read file " <> path }
  }
}

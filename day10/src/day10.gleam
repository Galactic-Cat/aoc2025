import argv
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp.{Match}
import gleam/string
import simplifile
import solution.{type Machine, Machine}

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

fn read(path) -> List(Machine) {
  io.println("Reading file " <> path)
  let assert Ok(indicator_pattern) = regexp.from_string("\\[[.#]+\\]")
  let assert Ok(button_pattern) = regexp.from_string("\\([\\d,]+\\)")
  let assert Ok(joltage_pattern) = regexp.from_string("\\{[\\d,]+\\}")

  case simplifile.read(path) {
    Ok(data) -> {
      string.split(data, "\n")
      |> list.map(fn(line) {
        let assert Ok(indicator_match) =
          list.first(regexp.scan(indicator_pattern, line))
        let Match(indicator_string, _) = indicator_match
        let indicators =
          string.drop_start(indicator_string, 1)
          |> string.drop_end(1)
          |> string.split("")
          |> list.map(fn(c) {
            case c {
              "#" -> True
              "." -> False
              _ -> panic
            }
          })
          |> create_dict(0)

        let buttons =
          list.map(regexp.scan(button_pattern, line), fn(button_match) {
            let Match(button_string, _) = button_match
            string.drop_start(button_string, 1)
            |> string.drop_end(1)
            |> string.split(",")
            |> list.map(fn(x) {
              let assert Ok(n) = int.parse(x)
              n
            })
          })

        let assert Ok(joltage_match) =
          list.first(regexp.scan(joltage_pattern, line))
        let Match(joltage_string, _) = joltage_match
        let joltage =
          string.drop_start(joltage_string, 1)
          |> string.drop_end(1)
          |> string.split(",")
          |> list.map(fn(x) {
            let assert Ok(n) = int.parse(x)
            n
          })
          |> create_dict(0)

        Machine(indicators, buttons, joltage)
      })
    }
    _ -> panic as { "Failed to read file " <> path }
  }
}

fn create_dict(input: List(a), index: Int) -> Dict(Int, a) {
  case list.first(input) {
    Ok(item) ->
      list.drop(input, 1)
      |> create_dict(index + 1)
      |> dict.insert(index, item)
    Error(_) -> dict.new()
  }
}

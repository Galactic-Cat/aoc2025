import gleam/int
import gleam/io
import gleam/list
import gleam/string

const initial = 50

pub fn solve(lines: List(String)) -> Int {
  io.println("Running on " <> int.to_string(list.length(lines)) <> " lines")

  run(lines, initial, 0)
}

fn run(lines: List(String), current: Int, count: Int) -> Int {
  case list.first(lines) {
    Ok(line) -> {
      let assert Ok(move) = int.parse(string.drop_start(line, 1))
      let newcurrent = case string.first(line) {
        Ok("R") -> rotate_r(current, move)
        Ok("L") -> rotate_l(current, move)
        Ok(_) -> panic as { "Could not parse line" <> line }
        Error(_) -> panic as { "Could not parse line " <> line }
      }

      case newcurrent {
        0 -> run(list.drop(lines, 1), newcurrent, count + 1)
        _ -> run(list.drop(lines, 1), newcurrent, count)
      }
    }
    Error(_) -> count
  }
}

fn rotate_l(current: Int, move: Int) -> Int {
  let new = current - { move % 100 }

  case new < 0 {
    True -> 100 + new
    False -> new
  }
}

fn rotate_r(current: Int, move: Int) -> Int {
  let new = current + { move % 100 }

  case new > 99 {
    True -> new - 100
    False -> new
  }
}

import gleam/int
import gleam/io
import gleam/list
import gleam/string

const initial = 50

pub fn solve(lines: List(String)) -> #(Int, Int) {
  io.println("Running on " <> int.to_string(list.length(lines)) <> " lines")

  #(run(lines, initial, 0, False), run(lines, initial, 0, True))
}

fn run(
  lines: List(String),
  current: Int,
  count: Int,
  count_zero_hits: Bool,
) -> Int {
  case list.first(lines) {
    Ok(line) -> {
      let assert Ok(move) = int.parse(string.drop_start(line, 1))
      let #(newcurrent, zero_hits) = case string.first(line) {
        Ok("R") -> rotate_r(current, move, count_zero_hits)
        Ok("L") -> rotate_l(current, move, count_zero_hits)
        Ok(_) -> panic as { "Could not parse line" <> line }
        Error(_) -> panic as { "Could not parse line " <> line }
      }

      run(list.drop(lines, 1), newcurrent, count + zero_hits, count_zero_hits)
    }
    Error(_) -> count
  }
}

fn rotate_l(current: Int, move: Int, count_zero_hits: Bool) -> #(Int, Int) {
  case current - move < 0, count_zero_hits {
    True, True -> {
      let #(newpos, zero_hits) =
        rotate_l(99, move - current - 1, count_zero_hits)
      #(newpos, zero_hits + 1)
    }
    True, False -> {
      let #(newpos, zero_hits) =
        rotate_l(99, move - current - 1, count_zero_hits)
      #(newpos, zero_hits)
    }
    False, _ ->
      case current - move == 0 {
        True -> #(0, 1)
        False -> #(current - move, 0)
      }
  }
}

fn rotate_r(current: Int, move: Int, count_zero_hits: Bool) -> #(Int, Int) {
  case current + move > 100, count_zero_hits {
    True, True -> {
      let #(newpos, zero_hits) =
        rotate_r(1, move - { 100 - current } - 1, count_zero_hits)
      #(newpos, zero_hits + 1)
    }
    True, False -> {
      let #(newpos, zero_hits) =
        rotate_r(1, move - { 100 - current } - 1, count_zero_hits)
      #(newpos, zero_hits)
    }
    False, _ ->
      case current + move == 100 {
        True -> #(0, 1)
        False -> #(current + move, 0)
      }
  }
}

import gleam/int
import gleam/list

pub type Range =
  #(Int, Int)

pub fn solve(ranges: List(Range), ids: List(Int)) -> #(Int, Nil) {
  #(
    list.map(ids, fn(id) { check_fresh(ranges, id) })
      |> int.sum(),
    Nil,
  )
}

fn check_fresh(ranges: List(Range), id: Int) -> Int {
  case list.first(ranges) {
    Ok(#(a, b)) ->
      case
        { a <= id && id <= b } || check_fresh(list.drop(ranges, 1), id) == 1
      {
        True -> 1
        False -> 0
      }
    Error(_) -> 0
  }
}

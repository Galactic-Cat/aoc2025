import gleam/list
import gleam/set.{type Set}

pub type Shape =
  #(Set(Int), Int, Int)

pub fn create(map: List(List(Bool))) -> Shape {
  #(create_helper(map, 0), 0, 0)
}

fn create_helper(map: List(List(Bool)), y: Int) -> Set(Int) {
  case list.first(map) {
    Ok(row) ->
      create_helper_helper(row, y, 0) |> set.union(create_helper(map, y + 1))
    Error(_) -> set.new()
  }
}

fn create_helper_helper(row: List(Bool), y: Int, x: Int) -> Set(Int) {
  case list.first(row) {
    Ok(True) ->
      create_helper_helper(list.drop(row, 1), y, x + 1) |> set.insert(y * 3 + x)
    Ok(False) -> create_helper_helper(list.drop(row, 1), y, x + 1)
    Error(_) -> set.new()
  }
}

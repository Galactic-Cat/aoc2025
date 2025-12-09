import gleam/int
import gleam/list

pub type Coordinate =
  #(Int, Int)

pub fn solve(input: List(Coordinate)) -> #(Int, Nil) {
  #(biggest_area(input), Nil)
}

fn area(a: Coordinate, b: Coordinate) -> Int {
  let #(ax, ay) = a
  let #(bx, by) = b
  let width = int.absolute_value(ax - bx) + 1
  let height = int.absolute_value(ay - by) + 1

  width * height
}

fn biggest_area(coordinates: List(Coordinate)) -> Int {
  case list.first(coordinates), list.length(coordinates) > 1 {
    Ok(item), True ->
      max_area_from(item, coordinates)
      |> int.max(biggest_area(list.drop(coordinates, 1)))
    _, _ -> 0
  }
}

fn max_area_from(a: Coordinate, bs: List(Coordinate)) -> Int {
  case list.first(bs) {
    Ok(b) ->
      area(a, b)
      |> int.max(max_area_from(a, list.drop(bs, 1)))
    Error(_) -> 0
  }
}

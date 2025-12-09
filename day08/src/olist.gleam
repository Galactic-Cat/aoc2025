import alist.{type AList}
import gleam/int
import gleam/io
import gleam/list

pub type OList(a) =
  AList(#(Float, a))

pub fn at(input: OList(a), index: Int) -> Result(a, Nil) {
  case alist.at(input, index) {
    Ok(#(_p, item)) -> Ok(item)
    Error(_) -> Error(Nil)
  }
}

pub fn create(items: List(#(Float, a))) -> OList(a) {
  case list.first(items) {
    Ok(#(p, item)) ->
      create(list.drop(items, 1))
      // |> fn(x) {
      //   io.println("w" <> int.to_string(alist.length(x)))
      //   x
      // }
      |> insert(p, item)
      |> echo
    Error(_) -> new()
  }
}

pub fn new() -> OList(a) {
  alist.new()
}

pub fn insert(input: OList(a), priority: Float, item: a) -> OList(a) {
  alist.insert(input, find_pos(input, priority, 0), #(priority, item))
}

pub fn map(input: OList(a), callback: fn(a) -> b) -> OList(b) {
  alist.map(input, fn(x) {
    let #(p, v) = x

    #(p, callback(v))
  })
}

fn find_pos(input: OList(a), priority: Float, index: Int) -> Int {
  case alist.at(input, index), alist.at(input, index + 1) {
    Ok(#(ap, _ai)), Ok(#(bp, _bi)) ->
      case ap <. priority, priority <. bp {
        True, True -> index + 1
        True, False -> find_pos(input, priority, index + 1)
        False, _ -> index
      }
    Ok(#(ap, _ai)), _ ->
      case ap <. priority {
        True -> index + 1
        False -> index
      }
    _, _ -> index
  }
}

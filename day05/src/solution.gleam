import gleam/int
import gleam/list

pub type Range =
  #(Int, Int)

pub type Updated(a) {
  Newer(a)
  Same(a)
}

pub fn solve(ranges: List(Range), ids: List(Int)) -> #(Int, Int) {
  #(
    list.map(ids, fn(id) { check_fresh(ranges, id) })
      |> int.sum(),
    unoverlap_ranges(ranges, [])
      |> check_all_fresh(),
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

fn check_all_fresh(ranges: List(Range)) -> Int {
  case list.first(ranges) {
    Ok(#(a, b)) -> { b - a + 1 } + check_all_fresh(list.drop(ranges, 1))
    Error(_) -> 0
  }
}

fn unoverlap_ranges(ranges: List(Range), acc: List(Range)) -> List(Range) {
  case list.first(ranges) {
    Ok(range) ->
      case unoverlap_ranges_add(acc, range) {
        Newer(new_acc) ->
          unoverlap_ranges(list.drop(ranges, 1), unoverlap_ranges(new_acc, []))
        Same(new_acc) -> unoverlap_ranges(list.drop(ranges, 1), new_acc)
      }
    Error(_) -> acc
  }
}

fn unoverlap_ranges_add(
  ranges: List(Range),
  range: Range,
) -> Updated(List(Range)) {
  case list.first(ranges) {
    Ok(next_range) ->
      case range_combine(range, next_range) {
        Ok(new_range) -> Newer([new_range, ..list.drop(ranges, 1)])
        Error(0) ->
          case unoverlap_ranges_add(list.drop(ranges, 1), range) {
            Newer(new_ranges) -> Newer([next_range, ..new_ranges])
            Same(new_ranges) -> Same([next_range, ..new_ranges])
          }
        Error(1) -> Same([range, ..ranges])
        Error(_) -> panic as { "huh" }
      }
    Error(_) -> Same([range])
  }
}

fn range_combine(a: Range, b: Range) -> Result(Range, Int) {
  let #(al, au) = a
  let #(bl, bu) = b

  // Ranges might not overlap at all
  case al > bu, bl > au {
    // Range a is higher than range b
    True, _ -> Error(0)
    // Range b is higher than range a
    _, True -> Error(1)
    // Ranges do overlap
    False, False ->
      case al < bl, au > bu {
        // a fully overlaps b
        True, True -> Ok(a)
        // a has a lower lower bound, but b has a higher upper bound
        True, False -> Ok(#(al, bu))
        // b has a lower lower bound, but a has a higher upper bound
        False, True -> Ok(#(bl, au))
        // b fully overlaps a
        False, False -> Ok(b)
      }
  }
}

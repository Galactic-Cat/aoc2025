import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub type Range =
  #(Int, Int)

pub fn solve(ranges: List(Range)) -> #(Int, Int) {
  let results =
    list.map(ranges, fn(range) {
      let #(lower, upper) = range
      let generated_range = generate_from_range(lower, upper, [])

      #(find_mirror(generated_range), find_repeating(generated_range))
    })

  #(
    int.sum(list.flat_map(results, first)),
    int.sum(list.flat_map(results, second)),
  )
}

fn find_mirror(values: List(Int)) -> List(Int) {
  list.filter(values, fn(value) {
    let str = int.to_string(value)

    case int.is_even(string.length(str)) {
      True -> {
        let assert Ok(pattern) =
          regexp.from_string(
            "^([0-9]{" <> int.to_string(string.length(str) / 2) <> "})\\1$",
          )

        regexp.check(pattern, str)
      }
      False -> False
    }
  })
}

fn find_repeating(values: List(Int)) -> List(Int) {
  list.filter(values, fn(value) {
    let str = int.to_string(value)
    let assert Ok(pattern) = regexp.from_string("^([0-9]+)\\1+$")

    regexp.check(pattern, str)
  })
}

fn first(tuple: #(_, b)) -> a {
  let #(a, _b) = tuple

  a
}

fn second(tuple: #(_, b)) -> b {
  let #(_a, b) = tuple

  b
}

fn generate_from_range(current: Int, max: Int, acc: List(Int)) -> List(Int) {
  case current <= max {
    True -> generate_from_range(current + 1, max, [current, ..acc])
    False -> acc
  }
}

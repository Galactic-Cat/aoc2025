import gleam/int
import gleam/list

pub type Battery =
  List(Int)

pub fn solve(batteries: List(Battery)) -> #(Int, Int) {
  #(int.sum(find_highests(batteries, 2)), int.sum(find_highests(batteries, 12)))
}

fn find_highests(batteries: List(Battery), length: Int) -> List(Int) {
  case list.first(batteries) {
    Ok(battery) -> [
      find_highest_combo(battery, length),
      ..find_highests(list.drop(batteries, 1), length)
    ]
    Error(_) -> []
  }
}

fn find_highest_combo(battery: Battery, length: Int) -> Int {
  case length == 1 {
    True -> {
      let #(result, _) = find_highest(battery, 0)

      result
    }
    False -> {
      let #(digit, digit_index) =
        find_highest(
          list.take(battery, list.length(battery) - { length - 1 }),
          0,
        )
      let combination =
        int.to_string(digit)
        <> int.to_string(find_highest_combo(
          list.drop(battery, digit_index + 1),
          length - 1,
        ))
      let assert Ok(result) = int.parse(combination)

      result
    }
  }
}

fn find_highest(battery: Battery, index: Int) -> #(Int, Int) {
  case list.first(battery) {
    Ok(n) -> {
      let #(rest, rest_index) = find_highest(list.drop(battery, 1), index + 1)

      case rest > n {
        True -> #(rest, rest_index)
        False -> #(n, index)
      }
    }
    Error(_) -> #(-1, index)
  }
}

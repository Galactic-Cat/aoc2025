import gleam/dict.{type Dict}
import gleam/int
import gleam/list

pub type State =
  Dict(Int, Bool)

pub type Button =
  List(Int)

pub type Joltage =
  Dict(Int, Int)

pub type Machine {
  Machine(State, List(Button), Joltage)
}

pub fn solve(input: List(Machine)) -> #(Int, Int) {
  #(
    list.map(input, initialize) |> int.sum(),
    list.map(input, configure) |> int.sum(),
  )
}

fn blank_joltage(target: Joltage) -> Joltage {
  blank_joltage_helper(0, dict.size(target))
}

fn blank_joltage_helper(index: Int, count: Int) -> Joltage {
  case index >= count {
    True -> dict.new()
    False ->
      blank_joltage_helper(index + 1, count)
      |> dict.insert(index, 0)
  }
}

fn blank_state(target: State) -> State {
  blank_state_helper(0, dict.size(target))
}

fn blank_state_helper(index: Int, count: Int) -> State {
  case index >= count {
    True -> dict.new()
    False ->
      blank_state_helper(index + 1, count)
      |> dict.insert(index, False)
  }
}

fn configure(machine: Machine) -> Int {
  let Machine(_indicators, buttons, target) = machine
  let initial_joltage = blank_joltage(target)

  configure_helper(target, [initial_joltage], buttons, 1)
}

fn configure_helper(
  target: Joltage,
  states: List(Joltage),
  buttons: List(Button),
  depth: Int,
) -> Int {
  let update_list =
    list.flat_map(states, fn(state) {
      list.map(buttons, fn(button) { update_joltage(state, button) })
    })
    |> list.filter(fn(new_joltage) { potential_joltage(target, new_joltage) })
  case
    list.fold(update_list, False, fn(acc, update) {
      acc || match_joltage(target, update)
    })
  {
    True -> depth
    False -> configure_helper(target, update_list, buttons, depth + 1)
  }
}

fn initialize(machine: Machine) -> Int {
  let Machine(target, buttons, _joltage) = machine
  let initial_state = blank_state(target)

  initialize_helper(target, [initial_state], buttons, 1)
}

fn initialize_helper(
  target: State,
  states: List(State),
  buttons: List(Button),
  depth: Int,
) -> Int {
  let update_list =
    list.flat_map(states, fn(state) {
      list.map(buttons, fn(button) { update_state(state, button) })
    })
  case
    list.fold(update_list, False, fn(acc, update) {
      acc || match_state(target, update)
    })
  {
    True -> depth
    False -> initialize_helper(target, update_list, buttons, depth + 1)
  }
}

fn match_joltage(alpha: Joltage, beta: Joltage) -> Bool {
  match_joltage_helper(alpha, beta, 0)
}

fn match_joltage_helper(alpha: Joltage, beta: Joltage, index: Int) -> Bool {
  case dict.get(alpha, index), dict.get(beta, index) {
    Ok(a), Ok(b) ->
      case a == b {
        True -> match_joltage_helper(alpha, beta, index + 1)
        False -> False
      }
    Error(_), Error(_) -> True
    _, _ -> False
  }
}

fn match_state(alpha: State, beta: State) -> Bool {
  match_state_helper(alpha, beta, 0)
}

fn match_state_helper(alpha: State, beta: State, index: Int) -> Bool {
  case dict.get(alpha, index), dict.get(beta, index) {
    Ok(True), Ok(True) -> match_state_helper(alpha, beta, index + 1)
    Ok(False), Ok(False) -> match_state_helper(alpha, beta, index + 1)
    Error(_), Error(_) -> True
    _, _ -> False
  }
}

fn potential_joltage(target: Joltage, current: Joltage) -> Bool {
  potential_joltage_helper(target, current, 0)
}

fn potential_joltage_helper(
  target: Joltage,
  current: Joltage,
  index: Int,
) -> Bool {
  case dict.get(target, index), dict.get(current, index) {
    Ok(t), Ok(c) ->
      case t >= c {
        True -> potential_joltage_helper(target, current, index + 1)
        False -> False
      }
    Error(_), Error(_) -> True
    _, _ -> False
  }
}

fn update_joltage(joltage: Joltage, button: Button) -> Joltage {
  case list.first(button) {
    Ok(index) ->
      case dict.get(joltage, index) {
        Ok(n) ->
          dict.insert(joltage, index, n + 1)
          |> update_joltage(list.drop(button, 1))
        Error(_) -> panic as { "Missing joltage " <> int.to_string(index) }
      }
    Error(_) -> joltage
  }
}

fn update_state(state: State, button: Button) -> State {
  case list.first(button) {
    Ok(index) ->
      case dict.get(state, index) {
        Ok(b) ->
          dict.insert(state, index, !b)
          |> update_state(list.drop(button, 1))
        Error(_) -> panic as { "Missing indicator " <> int.to_string(index) }
      }
    Error(_) -> state
  }
}

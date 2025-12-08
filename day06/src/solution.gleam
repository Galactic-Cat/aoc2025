import gleam/dict
import gleam/int
import gleam/list
import grid.{type Grid, type Row}

pub type Column {
  Op(Operator)
  Number(Int)
}

pub type Column2 {
  Add2
  Multiply2
  Empty2
  Number2(Int)
}

pub type Operator {
  Add
  Multiply
}

pub fn solve(input: Grid(Column)) -> Int {
  calculate(input)
  |> int.sum()
}

pub fn solve2(input: Grid(Column2)) -> Int {
  todo
}

fn calculate(input: Grid(Column)) -> List(Int) {
  let operands = get_operands(input)
  let #(height, _width) = grid.size(input)

  grid.drop_row(input, height - 1)
  |> calculate_columns(operands, 0)
}

fn calculate_columns(
  input: Grid(Column),
  operands: List(Operator),
  x: Int,
) -> List(Int) {
  case grid.slice_column(input, x), list.first(operands) {
    Ok(col), Ok(Add) -> [
      int.sum(unlift(col)),
      ..calculate_columns(input, list.drop(operands, 1), x + 1)
    ]
    Ok(col), Ok(Multiply) -> [
      int.product(unlift(col)),
      ..calculate_columns(input, list.drop(operands, 1), x + 1)
    ]
    _, _ -> []
  }
}

fn unlift(input: List(Column)) -> List(Int) {
  list.map(input, fn(x) {
    case x {
      Op(_) -> panic as "Cannot unlift operand"
      Number(n) -> n
    }
  })
}

fn get_groups(input: Grid(Column2), x: Int) -> List(#(Int, Int)) {
  case grid.slice_column(input, x) {
    Ok(col) ->
      case empty_column(col) {
        True -> get_groups(input, x + 1)
        False -> {
          let end = group_end(input, x)
          [#(x, end), ..get_groups(input, x + 1)]
        }
      }
    Error(_) -> []
  }
}

fn empty_column(column: List(Column2)) -> Bool {
  case list.first(column) {
    Ok(Empty2) -> empty_column(list.drop(column, 1))
    Ok(_) -> False
    Error(Nil) -> True
  }
}

fn get_operands(input: Grid(Column)) -> List(Operator) {
  let #(height, _width) = grid.size(input)

  case dict.get(input, height - 1) {
    Ok(last_row) -> get_operands_row(last_row, 0)
    Error(_) -> panic as { "Failed to read last row" }
  }
}

fn get_operands_row(input: Row(Column), x: Int) -> List(Operator) {
  case dict.get(input, x) {
    Ok(Number(z)) ->
      panic as { "Found " <> int.to_string(z) <> " in operand row" }
    Ok(Op(o)) -> [o, ..get_operands_row(input, x + 1)]
    Error(_) -> []
  }
}

fn group_end(grid: Grid(Column2), x: Int) -> Int {
  case grid.slice_column(grid, x) {
    Ok(col) ->
      case empty_column(col) {
        True -> x - 1
        False -> group_end(grid, x + 1)
      }
    Error(_) -> x - 1
  }
}

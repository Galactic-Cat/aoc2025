import gleam/dict.{type Dict}
import gleam/list

pub type Row(a) =
  Dict(Int, a)

pub type Grid(a) =
  Dict(Int, Dict(Int, a))

pub type Address =
  #(Int, Int)

pub fn create(origin: List(List(a))) -> Grid(a) {
  create_grid(origin, 0)
}

pub fn get(grid: Grid(a), x: Int, y: Int) -> Result(a, Nil) {
  case dict.get(grid, y) {
    Ok(row) -> dict.get(row, x)
    Error(_) -> Error(Nil)
  }
}

pub fn map(grid: Grid(a), callback: fn(a) -> b) -> Grid(b) {
  map_grid(grid, callback, 0)
}

pub fn map_coordinates(
  grid: Grid(a),
  callback: fn(Grid(a), Int, Int) -> b,
) -> Grid(b) {
  map_coordinates_grid(grid, callback, 0)
}

pub fn reduce(grid: Grid(a), callback: fn(a, b) -> b, zero: b) -> b {
  reduce_grid(zero, grid, callback, 0)
}

pub fn to_list(grid: Grid(a)) -> List(List(a)) {
  to_list_grid(grid, 0)
}

pub fn to_string(grid: Grid(a), mapper: fn(a) -> String) -> String {
  let assert Ok(result) =
    map(grid, mapper)
    |> to_list()
    |> list.map(fn(row) {
      let assert Ok(concat) = list.reduce(row, fn(x, acc) { x <> acc })
      concat
    })
    |> list.reduce(fn(row, acc) { row <> "\n" <> acc })

  result
}

fn create_grid(origin: List(List(a)), y: Int) -> Grid(a) {
  case list.first(origin) {
    Ok(r) -> {
      let row = create_row(r, 0)
      create_grid(list.drop(origin, 1), y + 1)
      |> dict.insert(y, row)
    }
    Error(_) -> dict.new()
  }
}

fn create_row(origin: List(a), x: Int) -> Row(a) {
  case list.first(origin) {
    Ok(item) -> {
      create_row(list.drop(origin, 1), x + 1)
      |> dict.insert(x, item)
    }
    Error(_) -> dict.new()
  }
}

fn map_coordinates_grid(
  grid: Grid(a),
  callback: fn(Grid(a), Int, Int) -> b,
  y: Int,
) -> Grid(b) {
  case dict.get(grid, y) {
    Ok(row) ->
      map_coordinates_grid(grid, callback, y + 1)
      |> dict.insert(y, map_coordinates_row(row, grid, callback, 0, y))
    Error(_) -> dict.new()
  }
}

fn map_coordinates_row(
  row: Row(a),
  grid: Grid(a),
  callback: fn(Grid(a), Int, Int) -> b,
  x: Int,
  y: Int,
) -> Row(b) {
  case dict.get(row, x) {
    Ok(_) ->
      map_coordinates_row(row, grid, callback, x + 1, y)
      |> dict.insert(x, callback(grid, x, y))
    Error(_) -> dict.new()
  }
}

fn map_grid(grid: Grid(a), callback: fn(a) -> b, y: Int) -> Grid(b) {
  case dict.get(grid, y) {
    Ok(row) ->
      map_grid(grid, callback, y + 1)
      |> dict.insert(y, map_row(row, callback, 0))
    Error(_) -> dict.new()
  }
}

fn map_row(row: Row(a), callback: fn(a) -> b, x: Int) -> Row(b) {
  case dict.get(row, x) {
    Ok(item) ->
      map_row(row, callback, x + 1)
      |> dict.insert(x, callback(item))
    Error(_) -> dict.new()
  }
}

fn reduce_grid(acc: b, grid: Grid(a), callback: fn(a, b) -> b, y: Int) -> b {
  case dict.get(grid, y) {
    Ok(row) ->
      reduce_row(acc, row, callback, 0)
      |> reduce_grid(grid, callback, y + 1)
    Error(_) -> acc
  }
}

fn reduce_row(acc: b, row: Row(a), callback: fn(a, b) -> b, x: Int) -> b {
  case dict.get(row, x) {
    Ok(item) ->
      callback(item, acc)
      |> reduce_row(row, callback, x + 1)
    Error(_) -> acc
  }
}

fn to_list_grid(grid: Grid(a), y: Int) -> List(List(a)) {
  case dict.get(grid, y) {
    Ok(row) -> [to_list_row(row, 0), ..to_list_grid(grid, y + 1)]
    Error(_) -> []
  }
}

fn to_list_row(row: Row(a), x: Int) -> List(a) {
  case dict.get(row, x) {
    Ok(cell) -> [cell, ..to_list_row(row, x + 1)]
    Error(_) -> []
  }
}

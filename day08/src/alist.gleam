import gleam/dict.{type Dict}
import gleam/list

pub type AList(a) =
  Dict(Int, a)

pub fn at(input: AList(a), index: Int) -> Result(a, Nil) {
  dict.get(input, index)
}

pub fn combine(a: AList(a), b: AList(a)) -> AList(a) {
  dict.combine(a, offset_index(b, length(a), 0), fn(_a, _b) {
    panic as { "dict collision on combine" }
  })
}

pub fn delete(input: AList(a), index: Int) -> AList(a) {
  take(input, index)
  |> dict.combine(drop(input, index + 1), fn(_a, _b) {
    panic as { "dict collision on delete" }
  })
}

pub fn drop(input: AList(a), count: Int) -> AList(a) {
  drop_helper(input, count, 0)
}

pub fn from_list(input: List(a)) -> AList(a) {
  from_list_helper(input, 0)
}

pub fn map(input: AList(a), callback: fn(a) -> b) -> AList(b) {
  map_helper(input, callback, 0)
}

pub fn map_index(input: AList(a), callback: fn(Int, a) -> b) -> AList(b) {
  map_index_helper(input, callback, 0)
}

pub fn new() -> AList(a) {
  dict.new()
}

pub fn insert(input: AList(a), index: Int, item: a) -> AList(a) {
  offset_index(input, index + 1, index)
  |> dict.insert(index, item)
  |> dict.combine(take(input, index), fn(_a, _b) {
    panic as { "dict collision on insert" }
  })
}

pub fn length(input: AList(a)) -> Int {
  dict.size(input)
}

pub fn push(input: AList(a), item: a) -> AList(a) {
  dict.insert(input, dict.size(input), item)
}

pub fn reduce(input: AList(a), callback: fn(a, b) -> b, zero: b) -> b {
  reduce_helper(input, callback, zero, 0)
}

pub fn reverse(input: AList(a)) -> AList(a) {
  reverse_helper(input, 0)
}

pub fn take(input: AList(a), count: Int) -> AList(a) {
  take_helper(input, count, 0)
}

pub fn to_list(input: AList(a)) -> List(a) {
  to_list_helper(input, 0)
}

fn drop_helper(input: AList(a), count: Int, index: Int) -> AList(a) {
  case index - count >= 0, at(input, index) {
    False, _ -> drop_helper(input, count, index + 1)
    _, Ok(item) ->
      drop_helper(input, count, index + 1)
      |> dict.insert(index - count, item)
    _, Error(_) -> dict.new()
  }
}

fn from_list_helper(input: List(a), count: Int) -> AList(a) {
  case list.first(input) {
    Ok(item) ->
      list.drop(input, 1)
      |> from_list_helper(count + 1)
      |> dict.insert(count, item)
    Error(_) -> new()
  }
}

fn map_helper(input: AList(a), callback: fn(a) -> b, index: Int) -> AList(b) {
  case at(input, index) {
    Ok(item) ->
      map_helper(input, callback, index + 1)
      |> dict.insert(index, callback(item))
    Error(_) -> new()
  }
}

fn map_index_helper(
  input: AList(a),
  callback: fn(Int, a) -> b,
  index: Int,
) -> AList(b) {
  case at(input, index) {
    Ok(item) ->
      map_index_helper(input, callback, index + 1)
      |> dict.insert(index, callback(index, item))
    Error(_) -> new()
  }
}

fn offset_index(input: AList(a), offset: Int, index: Int) -> AList(a) {
  case at(input, index) {
    Ok(item) ->
      offset_index(input, offset, index + 1)
      |> dict.insert(index + offset, item)
    Error(_) -> {
      new()
    }
  }
}

fn reduce_helper(
  input: AList(a),
  callback: fn(a, b) -> b,
  zero: b,
  index: Int,
) -> b {
  case at(input, index) {
    Ok(item) -> {
      let acc = reduce_helper(input, callback, zero, index + 1)
      callback(item, acc)
    }
    Error(_) -> zero
  }
}

fn reverse_helper(input: AList(a), index: Int) -> AList(a) {
  case at(input, index) {
    Ok(item) ->
      reverse_helper(input, index)
      |> push(item)
    Error(_) -> new()
  }
}

fn take_helper(input: AList(a), count: Int, index: Int) -> AList(a) {
  case index >= count, at(input, index) {
    True, _ -> dict.new()
    _, Ok(item) ->
      take_helper(input, count, index + 1)
      |> dict.insert(index, item)
    _, Error(_) -> new()
  }
}

fn to_list_helper(input: AList(a), index: Int) -> List(a) {
  case at(input, index) {
    Ok(item) -> [item, ..to_list_helper(input, index + 1)]
    Error(_) -> []
  }
}

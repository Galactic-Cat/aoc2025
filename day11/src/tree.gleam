import gleam/dict.{type Dict}

pub type Tree(a) {
  Branch(a, Dict(Int, Tree(a)))
  Leaf(a)
}

pub fn attach(node: Tree(a), value: a) -> Tree(a) {
  case node {
    Branch(branch_value, leaves) ->
      Branch(branch_value, dict.insert(leaves, dict.size(leaves), Leaf(value)))
    Leaf(branch_value) ->
      Branch(branch_value, dict.new() |> dict.insert(0, Leaf(value)))
  }
}

pub fn detach(node: Tree(a), index: Int) -> Result(Tree(a), Nil) {
  case node {
    Branch(branch_value, leaves) ->
      Ok(Branch(
        branch_value,
        dict.delete(leaves, index) |> decrease_index(index + 1),
      ))
    Leaf(_) -> Error(Nil)
  }
}

pub fn value(node: Tree(a)) -> a {
  case node {
    Branch(a, _) -> a
    Leaf(a) -> a
  }
}

pub fn new(value: a) -> Tree(a) {
  Leaf(value)
}

fn decrease_index(input: Dict(Int, a), index: Int) -> Dict(Int, a) {
  case dict.get(input, index) {
    Ok(item) ->
      dict.insert(input, index - 1, item)
      |> dict.delete(index)
      |> decrease_index(index + 1)
    Error(_) -> input
  }
}
